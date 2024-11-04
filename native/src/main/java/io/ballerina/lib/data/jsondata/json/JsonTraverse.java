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

package io.ballerina.lib.data.jsondata.json;

import io.ballerina.lib.data.jsondata.utils.Constants;
import io.ballerina.lib.data.jsondata.utils.DataUtils;
import io.ballerina.lib.data.jsondata.utils.DiagnosticErrorCode;
import io.ballerina.lib.data.jsondata.utils.DiagnosticLog;
import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.TypeTags;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.flags.SymbolFlags;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.Field;
import io.ballerina.runtime.api.types.IntersectionType;
import io.ballerina.runtime.api.types.MapType;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.TupleType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.UnionType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.utils.ValueUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;

import java.util.ArrayDeque;
import java.util.Deque;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Stack;

import static io.ballerina.lib.data.jsondata.utils.Constants.ENABLE_CONSTRAINT_VALIDATION;

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
            Object allowDataProjection = options.get(Constants.ALLOW_DATA_PROJECTION);
            if (allowDataProjection instanceof Boolean) {
                jsonTree.allowDataProjection = false;
            } else if (allowDataProjection instanceof BMap<?, ?>) {
                jsonTree.allowDataProjection = true;
                jsonTree.absentAsNilableType =
                        (Boolean) ((BMap<?, ?>) allowDataProjection).get(Constants.ABSENT_AS_NILABLE_TYPE);
                jsonTree.nilAsOptionalField =
                        (Boolean) ((BMap<?, ?>) allowDataProjection).get(Constants.NIL_AS_OPTIONAL_FIELD);
            }
            return jsonTree.traverseJson(json, type);
        } finally {
            jsonTree.reset();
        }
    }

    public static Object traverse(Object json, BMap<BString, Object> options, BTypedesc typed) {
        Object convertedValue = traverse(json, options, typed.getDescribingType());
        if (convertedValue instanceof BError) {
            return convertedValue;
        }
        return DataUtils.validateConstraints(convertedValue, typed,
                (Boolean) options.get(ENABLE_CONSTRAINT_VALIDATION));
    }

    private static class JsonTree {
        Field currentField;
        Stack<Map<String, Field>> fieldHierarchy = new Stack<>();
        Stack<Type> restType = new Stack<>();
        Deque<String> fieldNames = new ArrayDeque<>();
        Type rootArray;
        boolean allowDataProjection = false;
        boolean nilAsOptionalField = false;
        boolean absentAsNilableType = false;

        void reset() {
            currentField = null;
            fieldHierarchy.clear();
            restType.clear();
            fieldNames.clear();
            rootArray = null;
            allowDataProjection = false;
            nilAsOptionalField = false;
            absentAsNilableType = false;
        }

        private Object traverseJson(Object json, Type type) {
            Type referredType = TypeUtils.getReferredType(type);
            switch (referredType.getTag()) {
                case TypeTags.RECORD_TYPE_TAG -> {
                    RecordType recordType = (RecordType) referredType;
                    fieldHierarchy.push(JsonCreator.getAllFieldsInRecord(recordType));
                    restType.push(recordType.getRestFieldType());
                    if (recordType.isReadOnly()) {
                        Object value = traverseMapJsonOrArrayJson(json,
                                        ValueCreator.createMapValue(TypeCreator
                                                .createMapType(PredefinedTypes.TYPE_ANYDATA)), referredType);
                        try {
                            return ValueUtils.convert(JsonCreator.constructReadOnlyValue(value), recordType);
                        } catch (BError e) {
                            throw DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE, type, json);
                        }
                    }
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
                        TypeTags.DECIMAL_TAG, TypeTags.STRING_TAG, TypeTags.CHAR_STRING_TAG , TypeTags.BYTE_TAG,
                        TypeTags.SIGNED8_INT_TAG, TypeTags.SIGNED16_INT_TAG, TypeTags.SIGNED32_INT_TAG,
                        TypeTags.UNSIGNED8_INT_TAG, TypeTags.UNSIGNED16_INT_TAG, TypeTags.UNSIGNED32_INT_TAG,
                        TypeTags.FINITE_TYPE_TAG -> {
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
                    throw DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE, type, json);
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
                case TypeTags.INTERSECTION_TAG -> {
                    Type effectiveType = ((IntersectionType) referredType).getEffectiveType();
                    if (!SymbolFlags.isFlagOn(SymbolFlags.READONLY, effectiveType.getFlags())) {
                        throw DiagnosticLog.error(DiagnosticErrorCode.UNSUPPORTED_TYPE, type);
                    }
                    for (Type constituentType : ((IntersectionType) referredType).getConstituentTypes()) {
                        if (constituentType.getTag() == TypeTags.READONLY_TAG) {
                            continue;
                        }
                        return JsonCreator.constructReadOnlyValue(traverseJson(json, constituentType));
                    }
                    throw DiagnosticLog.error(DiagnosticErrorCode.UNSUPPORTED_TYPE, type);
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
                        continue;
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

                if (nilAsOptionalField && !currentFieldType.isNilable() && mapValue == null
                        && SymbolFlags.isFlagOn(currentField.getFlags(), SymbolFlags.OPTIONAL)) {
                    continue;
                }

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
                    if (!allowDataProjection && arrayType.getState() == ArrayType.ArrayState.CLOSED
                            && expectedArraySize < sourceArraySize) {
                        throw DiagnosticLog.error(DiagnosticErrorCode.ARRAY_SIZE_MISMATCH);
                    }

                    Type elementType = arrayType.getElementType();
                    if (expectedArraySize == -1 || expectedArraySize > sourceArraySize) {
                        traverseArrayMembers(array.getLength(), array, elementType, currentJsonNode);
                    } else {
                        traverseArrayMembers(expectedArraySize, array, elementType, currentJsonNode);
                    }
                }
                case TypeTags.TUPLE_TAG -> {
                    TupleType tupleType = (TupleType) rootArray;
                    Type restType = tupleType.getRestType();
                    int expectedTupleTypeCount = tupleType.getTupleTypes().size();
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
                    ((BMap<BString, Object>) currentJsonNode).put(key, convertToBasicType(jsonMember, restFieldType));
                }
                default -> {
                    nextJsonValue = traverseJson(jsonMember, restFieldType);
                    ((BMap<BString, Object>) currentJsonNode).put(key, nextJsonValue);
                }
            }
        }

        private void checkOptionalFieldsAndLogError(Map<String, Field> currentField) {
            currentField.values().forEach(field -> {
                if (field.getFieldType().isNilable() && absentAsNilableType) {
                    return;
                }
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
                    throw DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE, targetType, String.valueOf(json));
                }
                throw DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_VALUE_FOR_FIELD, String.valueOf(json),
                        targetType, getCurrentFieldPath());
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
