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
import io.ballerina.runtime.api.utils.JsonUtils;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
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

    public static Object traverse(Object json, Type type) {
        JsonTree jsonTree = tlJsonTree.get();
        try {
            return jsonTree.traverseJson(json, type);
        } catch (BError e) {
            return e;
        } finally {
            jsonTree.reset();
        }
    }

    static class JsonTree {

        Object currentJsonNode;
        Field currentField;
        Stack<Map<String, Field>> fieldHierarchy = new Stack<>();
        Stack<Type> restType = new Stack<>();
        Deque<Object> nodesStack = new ArrayDeque<>();
        Deque<String> fieldNames = new ArrayDeque<>();
        Type rootArray;

        void reset() {
            currentJsonNode = null;
            currentField = null;
            fieldHierarchy.clear();
            restType.clear();
            nodesStack.clear();
            fieldNames.clear();
            rootArray = null;
        }

        public Object traverseJson(Object json, Type type) {
            Type referredType = TypeUtils.getReferredType(type);
            switch (referredType.getTag()) {
                case TypeTags.RECORD_TYPE_TAG:
                    RecordType recordType = (RecordType) referredType;
                    this.fieldHierarchy.push(new HashMap<>(recordType.getFields()));
                    this.restType.push(recordType.getRestFieldType());
                    currentJsonNode = ValueCreator.createRecordValue(recordType);
                    nodesStack.push(currentJsonNode);
                    traverseMapJsonOrArrayJson(json, referredType);
                    break;
                case TypeTags.ARRAY_TAG:
                    rootArray = referredType;
                    currentJsonNode = ValueCreator.createArrayValue((ArrayType) referredType);
                    nodesStack.push(currentJsonNode);
                    traverseMapJsonOrArrayJson(json, referredType);
                    break;
                case TypeTags.TUPLE_TAG:
                    rootArray = referredType;
                    currentJsonNode = ValueCreator.createTupleValue((TupleType) referredType);
                    nodesStack.push(currentJsonNode);
                    traverseMapJsonOrArrayJson(json, referredType);
                    break;
                case TypeTags.NULL_TAG:
                case TypeTags.BOOLEAN_TAG:
                case TypeTags.INT_TAG:
                case TypeTags.FLOAT_TAG:
                case TypeTags.DECIMAL_TAG:
                case TypeTags.STRING_TAG:
                    return convertToBasicType(json, referredType);
                case TypeTags.UNION_TAG:
                    for (Type memberType : ((UnionType) referredType).getMemberTypes()) {
                        try {
                            return traverseJson(json, memberType);
                        } catch (Exception e) {
                            // Ignore
                        }
                    }
                    return DiagnosticLog.error(DiagnosticErrorCode.INVALID_TYPE, type, PredefinedTypes.TYPE_ANYDATA);
                case TypeTags.JSON_TAG:
                case TypeTags.ANYDATA_TAG:
                    return json;
                default:
                    return DiagnosticLog.error(DiagnosticErrorCode.INVALID_TYPE, type, PredefinedTypes.TYPE_ANYDATA);
            }
            return currentJsonNode;
        }

        private void traverseMapJsonOrArrayJson(Object json, Type type) {
            Object parentJsonNode = nodesStack.peek();
            if (json instanceof BMap map) {
                traverseMapValue(map, parentJsonNode);
            } else if (json instanceof BArray) {
                traverseArrayValue(json, parentJsonNode);
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
            nodesStack.pop();
        }

        private void traverseMapValue(BMap<BString, Object> map, Object parentJsonNode) {
            for (BString key : map.getKeys()) {
                currentField = fieldHierarchy.peek().remove(key.toString());
                if (currentField == null) {
                    // Add to the rest field
                    if (restType.peek() != null) {
                        Type restFieldType = TypeUtils.getReferredType(restType.peek());
                        addRestField(restFieldType, key, map.get(key));
                    }
                    continue;
                }

                fieldNames.push(currentField.getFieldName());
                Type currentFieldType = TypeUtils.getReferredType(currentField.getFieldType());
                int currentFieldTypeTag = currentFieldType.getTag();
                Object mapValue = map.get(key);

                switch (currentFieldTypeTag) {
                    case TypeTags.MAP_TAG:
                        if (!checkTypeCompatibility(((MapType) currentFieldType).getConstrainedType(), mapValue)) {
                            throw DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_VALUE_FOR_FIELD, mapValue,
                                    currentFieldType, getCurrentFieldPath());
                        }
                        ((BMap<BString, Object>) currentJsonNode).put(StringUtils.fromString(fieldNames.pop()),
                                mapValue);
                        break;
                    case TypeTags.NULL_TAG:
                    case TypeTags.BOOLEAN_TAG:
                    case TypeTags.INT_TAG:
                    case TypeTags.FLOAT_TAG:
                    case TypeTags.DECIMAL_TAG:
                    case TypeTags.STRING_TAG:
                        Object value = convertToBasicType(mapValue, currentFieldType);
                        ((BMap<BString, Object>) currentJsonNode).put(StringUtils.fromString(fieldNames.pop()), value);
                        break;
                    default:
                        currentJsonNode = traverseJson(mapValue, currentFieldType);
                        ((BMap<BString, Object>) parentJsonNode).put(key, currentJsonNode);
                        currentJsonNode = parentJsonNode;
                }
            }
            Map<String, Field> currentField = fieldHierarchy.pop();
            checkOptionalFieldsAndLogError(currentField);
            restType.pop();
        }

        private void traverseArrayValue(Object json, Object parentJsonNode) {
            BArray array = (BArray) json;
            switch (rootArray.getTag()) {
                case TypeTags.ARRAY_TAG:
                    ArrayType arrayType = (ArrayType) rootArray;
                    int expectedArraySize = arrayType.getSize();
                    if (expectedArraySize > array.getLength()) {
                        throw DiagnosticLog.error(DiagnosticErrorCode.ARRAY_SIZE_MISMATCH);
                    }

                    Type elementType = arrayType.getElementType();
                    if (expectedArraySize == -1) {
                        traverseArrayMembers(array.getLength(), array, elementType, parentJsonNode);
                    } else {
                        traverseArrayMembers(expectedArraySize, array, elementType, parentJsonNode);
                    }
                    break;
                case TypeTags.TUPLE_TAG:
                    TupleType tupleType = (TupleType) rootArray;
                    Type restType = tupleType.getRestType();
                    int expectedTupleTypeCount = tupleType.getTupleTypes().size();
                    if (expectedTupleTypeCount > array.getLength()) {
                        throw DiagnosticLog.error(DiagnosticErrorCode.ARRAY_SIZE_MISMATCH);
                    }

                    for (int i = 0; i < array.getLength(); i++) {
                        Object jsonMember = array.get(i);
                        if (i < expectedTupleTypeCount) {
                            currentJsonNode = traverseJson(jsonMember, tupleType.getTupleTypes().get(i));
                        } else if (restType != null) {
                            currentJsonNode = traverseJson(jsonMember, restType);
                        } else {
                            continue;
                        }
                        ((BArray) parentJsonNode).add(i, currentJsonNode);
                    }
                    break;
            }
            currentJsonNode = parentJsonNode;
        }

        private void traverseArrayMembers(long length, BArray array, Type elementType, Object parentJsonNode) {
            for (int i = 0; i < length; i++) {
                Object jsonMember = array.get(i);
                currentJsonNode = traverseJson(jsonMember, elementType);
                ((BArray) parentJsonNode).add(i, currentJsonNode);
            }
        }

        private void addRestField(Type restFieldType, BString key, Object jsonMember) {
            switch (restFieldType.getTag()) {
                case TypeTags.ANYDATA_TAG:
                case TypeTags.JSON_TAG:
                    ((BMap<BString, Object>) currentJsonNode).put(key, jsonMember);
                    break;
                case TypeTags.BOOLEAN_TAG:
                case TypeTags.INT_TAG:
                case TypeTags.FLOAT_TAG:
                case TypeTags.DECIMAL_TAG:
                case TypeTags.STRING_TAG:
                    if (checkTypeCompatibility(restFieldType, jsonMember)) {
                        ((BMap<BString, Object>) currentJsonNode).put(key, jsonMember);
                    }
                    break;
                default:
                    return;
            }
        }

        private boolean checkTypeCompatibility(Type constraintType, Object json) {
            if (json instanceof BMap) {
                BMap<BString, Object> map = (BMap<BString, Object>) json;
                for (BString key : map.getKeys()) {
                    if (!checkTypeCompatibility(constraintType, map.get(key))) {
                        return false;
                    }
                }
                return true;
            } else if ((json instanceof BString && constraintType.getTag() == TypeTags.STRING_TAG)
                    || (json instanceof Long && constraintType.getTag() == TypeTags.INT_TAG)
                    || (json instanceof Double && (constraintType.getTag() == TypeTags.FLOAT_TAG
                    || constraintType.getTag() == TypeTags.DECIMAL_TAG))
                    || (Boolean.class.isInstance(json) && constraintType.getTag() == TypeTags.BOOLEAN_TAG)
                    || (json == null && constraintType.getTag() == TypeTags.NULL_TAG)) {
                return true;
            } else {
                return false;
            }
        }

        private void checkOptionalFieldsAndLogError(Map<String, Field> currentField) {
            currentField.values().forEach(field -> {
                if (SymbolFlags.isFlagOn(field.getFlags(), SymbolFlags.REQUIRED)) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.REQUIRED_FIELD_NOT_PRESENT, field.getFieldName());
                }
            });
        }

        private Object convertToBasicType(Object json, Type targetType) {
            if (targetType.getTag() == TypeTags.READONLY_TAG) {
                return json;
            }
            try {
                // TODO: string x = check jsondata:fromJsonWithType(5); should it error?
                return JsonUtils.convertJSON(json, targetType);
            } catch (Exception e) {
                if (fieldNames.isEmpty()) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE, targetType, json);
                }
                throw DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_VALUE_FOR_FIELD, json, targetType,
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
