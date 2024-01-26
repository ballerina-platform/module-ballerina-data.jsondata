/*
 * Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.stdlib.data.jsondata.json;

import io.ballerina.runtime.api.TypeTags;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.TupleType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.stdlib.data.jsondata.FromString;
import io.ballerina.stdlib.data.jsondata.utils.Constants;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Optional;

/**
 * Create objects for partially parsed json.
 *
 * @since 0.1.0
 */
public class JsonCreator {

    static BMap<BString, Object> initRecordValue(Type expectedType) throws JsonParser.JsonParserException {
        if (expectedType.getTag() != TypeTags.RECORD_TYPE_TAG) {
            throw new JsonParser.JsonParserException("expected record type for input type");
        }

        return ValueCreator.createRecordValue((RecordType) expectedType);
    }

    static BArray initArrayValue(Type expectedType) throws JsonParser.JsonParserException {
        if (expectedType.getTag() == TypeTags.TUPLE_TAG) {
            return ValueCreator.createTupleValue((TupleType) expectedType);
        } else if (expectedType.getTag() == TypeTags.ARRAY_TAG) {
            return ValueCreator.createArrayValue((ArrayType) expectedType);
        } else {
            throw new JsonParser.JsonParserException("expected array or tuple type for input type");
        }
    }

    static Optional<BMap<BString, Object>> initNewMapValue(JsonParser.StateMachine sm)
            throws JsonParser.JsonParserException {
        sm.parserContexts.push(JsonParser.StateMachine.ParserContext.MAP);
        Type expType = sm.expectedTypes.peek();
        if (expType == null) {
            return Optional.empty();
        }
        Type currentType = TypeUtils.getReferredType(expType);

        if (sm.currentJsonNode != null) {
            sm.nodesStack.push(sm.currentJsonNode);
        }

        BMap<BString, Object> nextMapValue;
        switch (currentType.getTag()) {
            case TypeTags.RECORD_TYPE_TAG:
                RecordType recordType = (RecordType) currentType;
                nextMapValue = ValueCreator.createRecordValue(recordType);
                sm.fieldHierarchy.push(new HashMap<>(recordType.getFields()));
                sm.restType.push(recordType.getRestFieldType());
                break;
            case TypeTags.JSON_TAG:
                nextMapValue = ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);
                sm.fieldHierarchy.push(new HashMap<>());
                sm.restType.push(sm.definedJsonType);
                sm.jsonFieldDepth++;
                break;
            case TypeTags.ANYDATA_TAG:
                nextMapValue = ValueCreator.createMapValue(Constants.ANYDATA_MAP_TYPE);
                sm.fieldHierarchy.push(new HashMap<>());
                sm.restType.push(sm.definedJsonType);
                sm.jsonFieldDepth++;
                break;
            default:
                throw new JsonParser.JsonParserException("invalid type in field " + getCurrentFieldPath(sm));
        }

        Object currentJson = sm.currentJsonNode;
        int valueTypeTag = TypeUtils.getType(currentJson).getTag();
        if (valueTypeTag == TypeTags.MAP_TAG || valueTypeTag == TypeTags.RECORD_TYPE_TAG) {
            // TODO: Fix -> Using fieldName as the key is wrong all the time when json as exp type.
            ((BMap<BString, Object>) currentJson).put(StringUtils.fromString(sm.fieldNames.peek()),
                    nextMapValue);
        }
        return Optional.of(nextMapValue);
    }

    static Optional<BArray> initNewArrayValue(JsonParser.StateMachine sm) throws JsonParser.JsonParserException {
        sm.parserContexts.push(JsonParser.StateMachine.ParserContext.ARRAY);
        Type expType = sm.expectedTypes.peek();
        if (expType == null) {
            return Optional.empty();
        }

        Object currentJsonNode = sm.currentJsonNode;
        BArray nextArrValue = initArrayValue(sm.expectedTypes.peek());
        if (currentJsonNode == null) {
            return Optional.ofNullable(nextArrValue);
        }

        sm.nodesStack.push(sm.currentJsonNode);
        return Optional.ofNullable(nextArrValue);
    }

    private static String getCurrentFieldPath(JsonParser.StateMachine sm) {
        Iterator<String> itr = sm.fieldNames.descendingIterator();

        StringBuilder result = new StringBuilder(itr.hasNext() ? itr.next() : "");
        while (itr.hasNext()) {
            result.append(".").append(itr.next());
        }
        return result.toString();
    }

    static String getCurrentFieldPath(JsonTraverse.JsonTree jsonTree) {
        Iterator<String> itr = jsonTree.fieldNames.descendingIterator();

        StringBuilder result = new StringBuilder(itr.hasNext() ? itr.next() : "");
        while (itr.hasNext()) {
            result.append(".").append(itr.next());
        }
        return result.toString();
    }

    static Object convertAndUpdateCurrentJsonNode(JsonParser.StateMachine sm, BString value, Type type)
            throws JsonParser.JsonParserException {
        Object currentJson = sm.currentJsonNode;
        Object convertedValue = FromString.fromStringWithType(value, type);
        // TODO: Remove null case after properly returning error.
        if (convertedValue == null || convertedValue instanceof BError) {
            throw new JsonParser.JsonParserException("incompatible value '" + value + "' for type '" +
                    type + "' in field '" + getCurrentFieldPath(sm) + "'");
        }

        Type currentJsonNodeType = TypeUtils.getType(currentJson);

        switch (currentJsonNodeType.getTag()) {
            case TypeTags.MAP_TAG:
            case TypeTags.RECORD_TYPE_TAG:
                ((BMap<BString, Object>) currentJson).put(StringUtils.fromString(sm.fieldNames.pop()),
                        convertedValue);
                return currentJson;
            case TypeTags.ARRAY_TAG:
                // Handle projection in array.
                ArrayType arrayType = (ArrayType) currentJsonNodeType;
                if (arrayType.getState() == ArrayType.ArrayState.CLOSED &&
                        arrayType.getSize() <= sm.arrayIndexes.peek()) {
                    return currentJson;
                }
                ((BArray) currentJson).add(sm.arrayIndexes.peek(), convertedValue);
                return currentJson;
            case TypeTags.TUPLE_TAG:
                ((BArray) currentJson).add(sm.arrayIndexes.peek(), convertedValue);
                return currentJson;
            default:
                return convertedValue;
        }
    }

    static void updateRecordFieldValue(BString fieldName, Object parent, Object currentJson) {
        switch (TypeUtils.getType(parent).getTag()) {
            case TypeTags.MAP_TAG:
            case TypeTags.RECORD_TYPE_TAG:
                ((BMap<BString, Object>) parent).put(fieldName, currentJson);
                 break;
        }
    }

    static Type getMemberType(Type expectedType, int index) {
        if (expectedType == null) {
            return null;
        }

        if (expectedType.getTag() == TypeTags.ARRAY_TAG) {
            return ((ArrayType) expectedType).getElementType();
        } else if (expectedType.getTag() == TypeTags.TUPLE_TAG) {
            return ((TupleType) expectedType).getTupleTypes().get(index);
        } else {
            return expectedType;
        }
    }
}
