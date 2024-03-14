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

import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.TypeTags;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.flags.SymbolFlags;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.Field;
import io.ballerina.runtime.api.types.MapType;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.TupleType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.UnionType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.utils.ValueUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BDecimal;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.stdlib.data.jsondata.utils.Constants;
import io.ballerina.stdlib.data.jsondata.utils.DiagnosticErrorCode;
import io.ballerina.stdlib.data.jsondata.utils.DiagnosticLog;

import java.util.ArrayDeque;
import java.util.Deque;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Stack;

/**
 * Traverse json tree.
 *
 * @since 0.1.0
 */
public class JsonTraverse {

    private static final ThreadLocal<JsonTree> tlJsonTree = ThreadLocal.withInitial(JsonTree::new);

    public static Object traverse(Object json, BMap<BString, Object> options, Type type) {
        JsonTree jsonTree = tlJsonTree.get();
        try {
            jsonTree.allowDataProjection = (boolean) options.get(Constants.ALLOW_DATA_PROJECTION);
            return jsonTree.traverseJson(json, type);
        } catch (BError e) {
            return e;
        } finally {
            jsonTree.reset();
        }
    }

    static class JsonTree {
        Field currentField;
        Stack<Map<String, Field>> fieldHierarchy = new Stack<>();
        Stack<Type> restType = new Stack<>();
        Deque<String> fieldNames = new ArrayDeque<>();
        Type rootArray;
        boolean allowDataProjection;

        void reset() {
            currentField = null;
            fieldHierarchy.clear();
            restType.clear();
            fieldNames.clear();
            rootArray = null;
        }

        public Object traverseJson(Object json, Type type) {
            Type referredType = TypeUtils.getReferredType(type);
            switch (referredType.getTag()) {
                case TypeTags.RECORD_TYPE_TAG -> {
                    RecordType recordType = (RecordType) referredType;
                    fieldHierarchy.push(JsonCreator.getAllFieldsInRecord(recordType));
                    restType.push(recordType.getRestFieldType());
                    return traverseMapJsonOrArrayJson(json,
                            ValueCreator.createRecordValue(type.getPackage(), type.getName()), referredType);
                }
                case TypeTags.ARRAY_TAG -> {
                    rootArray = referredType;
                    return traverseMapJsonOrArrayJson(json, ValueCreator.createArrayValue((ArrayType) referredType),
                            referredType);
                }
                case TypeTags.TUPLE_TAG -> {
                    rootArray = referredType;
                    return traverseMapJsonOrArrayJson(json, ValueCreator.createTupleValue((TupleType) referredType),
                            referredType);
                }
                case TypeTags.NULL_TAG, TypeTags.BOOLEAN_TAG, TypeTags.INT_TAG, TypeTags.FLOAT_TAG,
                        TypeTags.DECIMAL_TAG, TypeTags.STRING_TAG, TypeTags.BYTE_TAG, TypeTags.SIGNED8_INT_TAG,
                        TypeTags.SIGNED16_INT_TAG, TypeTags.SIGNED32_INT_TAG, TypeTags.UNSIGNED8_INT_TAG,
                        TypeTags.UNSIGNED16_INT_TAG, TypeTags.UNSIGNED32_INT_TAG -> {
                    return convertToBasicType(json, referredType);
                }
                case TypeTags.UNION_TAG -> {
                    for (Type memberType : ((UnionType) referredType).getMemberTypes()) {
                        try {
                            return traverseJson(json, memberType);
                        } catch (Exception e) {
                            // Ignore
                        }
                    }
                    throw DiagnosticLog.error(DiagnosticErrorCode.INVALID_TYPE, type, PredefinedTypes.TYPE_ANYDATA);
                }
                case TypeTags.JSON_TAG, TypeTags.ANYDATA_TAG -> {
                    return json;
                }
                case TypeTags.MAP_TAG -> {
                    MapType mapType = (MapType) referredType;
                    fieldHierarchy.push(new HashMap<>());
                    restType.push(mapType.getConstrainedType());
                    return traverseMapJsonOrArrayJson(json, ValueCreator.createMapValue(mapType), referredType);
                }
                default ->
                        throw DiagnosticLog.error(DiagnosticErrorCode.INVALID_TYPE, type, PredefinedTypes.TYPE_ANYDATA);
            }
        }

        private Object traverseMapJsonOrArrayJson(Object json, Object currentJsonNode, Type type) {
            if (json instanceof BMap bMap) {
                return traverseMapValue(bMap, currentJsonNode);
            } else if (json instanceof BArray bArray) {
                return traverseArrayValue(bArray, currentJsonNode);
            } else {
                // JSON value not compatible with map or array.
                if (type.getTag() == TypeTags.RECORD_TYPE_TAG) {
                    this.fieldHierarchy.pop();
                    this.restType.pop();
                }

                if (fieldNames.isEmpty()) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE, type, json);
                }
                throw DiagnosticLog.error(DiagnosticErrorCode.INVALID_TYPE_FOR_FIELD, getCurrentFieldPath());
            }
        }

        private Object traverseMapValue(BMap<BString, Object> map, Object currentJsonNode) {
            for (BString key : map.getKeys()) {
                currentField = fieldHierarchy.peek().remove(key.toString());
                if (currentField == null) {
                    // Add to the rest field
                    if (restType.peek() != null) {
                        Type restFieldType = TypeUtils.getReferredType(restType.peek());
                        addRestField(restFieldType, key, map.get(key), currentJsonNode);
                    }
                    if (allowDataProjection) {
                        continue;
                    }
                    throw DiagnosticLog.error(DiagnosticErrorCode.UNDEFINED_FIELD, key);
                }

                String fieldName = currentField.getFieldName();
                fieldNames.push(fieldName);
                Type currentFieldType = TypeUtils.getReferredType(currentField.getFieldType());
                int currentFieldTypeTag = currentFieldType.getTag();
                Object mapValue = map.get(key);

                switch (currentFieldTypeTag) {
                    case TypeTags.NULL_TAG, TypeTags.BOOLEAN_TAG, TypeTags.INT_TAG, TypeTags.FLOAT_TAG,
                            TypeTags.DECIMAL_TAG, TypeTags.STRING_TAG -> {
                        Object value = convertToBasicType(mapValue, currentFieldType);
                        ((BMap<BString, Object>) currentJsonNode).put(StringUtils.fromString(fieldNames.pop()), value);
                    }
                    default ->
                        ((BMap<BString, Object>) currentJsonNode).put(StringUtils.fromString(fieldName),
                                traverseJson(mapValue, currentFieldType));
                }
            }
            Map<String, Field> currentField = fieldHierarchy.pop();
            checkOptionalFieldsAndLogError(currentField);
            restType.pop();
            return currentJsonNode;
        }

        private Object traverseArrayValue(BArray array, Object currentJsonNode) {
            switch (rootArray.getTag()) {
                case TypeTags.ARRAY_TAG -> {
                    ArrayType arrayType = (ArrayType) rootArray;
                    int expectedArraySize = arrayType.getSize();
                    long sourceArraySize = array.getLength();
                    if (expectedArraySize > sourceArraySize) {
                        throw DiagnosticLog.error(DiagnosticErrorCode.ARRAY_SIZE_MISMATCH);
                    }

                    if (!allowDataProjection && expectedArraySize < sourceArraySize) {
                        throw DiagnosticLog.error(DiagnosticErrorCode.ARRAY_SIZE_MISMATCH);
                    }

                    Type elementType = arrayType.getElementType();
                    if (expectedArraySize == -1) {
                        traverseArrayMembers(array.getLength(), array, elementType, currentJsonNode);
                    } else {
                        traverseArrayMembers(expectedArraySize, array, elementType, currentJsonNode);
                    }
                }
                case TypeTags.TUPLE_TAG -> {
                    TupleType tupleType = (TupleType) rootArray;
                    Type restType = tupleType.getRestType();
                    int expectedTupleTypeCount = tupleType.getTupleTypes().size();
                    if (expectedTupleTypeCount > array.getLength()) {
                        throw DiagnosticLog.error(DiagnosticErrorCode.ARRAY_SIZE_MISMATCH);
                    }
                    for (int i = 0; i < array.getLength(); i++) {
                        Object jsonMember = array.get(i);
                        Object nextJsonNode;
                        if (i < expectedTupleTypeCount) {
                            nextJsonNode = traverseJson(jsonMember, tupleType.getTupleTypes().get(i));
                        } else if (restType != null) {
                            nextJsonNode = traverseJson(jsonMember, restType);
                        } else if (!allowDataProjection) {
                            throw DiagnosticLog.error(DiagnosticErrorCode.ARRAY_SIZE_MISMATCH);
                        } else {
                            continue;
                        }
                        ((BArray) currentJsonNode).add(i, nextJsonNode);
                    }
                }
            }
            return currentJsonNode;
        }

        private void traverseArrayMembers(long length, BArray array, Type elementType, Object currentJsonNode) {
            for (int i = 0; i < length; i++) {
                ((BArray) currentJsonNode).add(i, traverseJson(array.get(i), elementType));
            }
        }

        private void addRestField(Type restFieldType, BString key, Object jsonMember, Object currentJsonNode) {
            Object nextJsonValue;
            switch (restFieldType.getTag()) {
                case TypeTags.ANYDATA_TAG, TypeTags.JSON_TAG ->
                        ((BMap<BString, Object>) currentJsonNode).put(key, jsonMember);
                case TypeTags.BOOLEAN_TAG, TypeTags.INT_TAG, TypeTags.FLOAT_TAG, TypeTags.DECIMAL_TAG,
                        TypeTags.STRING_TAG -> {
                    if (checkTypeCompatibility(restFieldType, jsonMember)) {
                        ((BMap<BString, Object>) currentJsonNode).put(key, jsonMember);
                    }
                }
                default -> {
                    nextJsonValue = traverseJson(jsonMember, restFieldType);
                    ((BMap<BString, Object>) currentJsonNode).put(key, nextJsonValue);
                }
            }
        }

        private boolean checkTypeCompatibility(Type type, Object json) {
            return ((json == null && type.getTag() == TypeTags.NULL_TAG)
                    || (json instanceof BString && type.getTag() == TypeTags.STRING_TAG)
                    || (isBallerinaInt(json) && type.getTag() == TypeTags.INT_TAG)
                    || (json instanceof Double && type.getTag() == TypeTags.FLOAT_TAG)
                    || ((json instanceof Double || json instanceof BDecimal) && type.getTag() == TypeTags.DECIMAL_TAG)
                    || (json instanceof Boolean && type.getTag() == TypeTags.BOOLEAN_TAG));
        }

        private boolean isBallerinaInt(Object val) {
            return val instanceof Number && !(val instanceof Double);
        }

        private void checkOptionalFieldsAndLogError(Map<String, Field> currentField) {
            currentField.values().forEach(field -> {
                if (SymbolFlags.isFlagOn(field.getFlags(), SymbolFlags.REQUIRED)) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.REQUIRED_FIELD_NOT_PRESENT, field.getFieldName());
                }
            });
        }

        private Object convertToBasicType(Object json, Type targetType) {
            try {
                return ValueUtils.convert(json, targetType);
            } catch (BError e) {
                if (fieldNames.isEmpty()) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE, targetType, json.toString());
                }
                throw DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_VALUE_FOR_FIELD, json.toString(), targetType,
                        getCurrentFieldPath());
            }
        }

        private String getCurrentFieldPath() {
            Iterator<String> itr = fieldNames.descendingIterator();
            StringBuilder sb = new StringBuilder(itr.hasNext() ? itr.next() : "");
            while (itr.hasNext()) {
                sb.append(".").append(itr.next());
            }
            return sb.toString();
        }
    }
}
