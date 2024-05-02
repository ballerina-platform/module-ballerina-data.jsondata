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

import io.ballerina.lib.data.jsondata.FromString;
import io.ballerina.lib.data.jsondata.utils.Constants;
import io.ballerina.lib.data.jsondata.utils.DiagnosticErrorCode;
import io.ballerina.lib.data.jsondata.utils.DiagnosticLog;
import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.TypeTags;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.flags.SymbolFlags;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.Field;
import io.ballerina.runtime.api.types.FiniteType;
import io.ballerina.runtime.api.types.IntersectionType;
import io.ballerina.runtime.api.types.MapType;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.TupleType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.UnionType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import org.ballerinalang.langlib.value.CloneReadOnly;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Stack;

/**
 * Create objects for partially parsed json.
 *
 * @since 0.1.0
 */
public class JsonCreator {

    private static final List<Type> BASIC_TYPE_MEMBER_TYPES = List.of(
            PredefinedTypes.TYPE_NULL,
            PredefinedTypes.TYPE_BOOLEAN,
            PredefinedTypes.TYPE_INT,
            PredefinedTypes.TYPE_FLOAT,
            PredefinedTypes.TYPE_DECIMAL
    );
    private static final UnionType UNION_OF_BASIC_TYPE_WITHOUT_STRING =
            TypeCreator.createUnionType(BASIC_TYPE_MEMBER_TYPES);

    static BMap<BString, Object> initRootMapValue(JsonParser.StateMachine sm) {
        Type expectedType = sm.expectedTypes.peek();
        sm.parserContexts.push(JsonParser.StateMachine.ParserContext.MAP);
        switch (expectedType.getTag()) {
            case TypeTags.RECORD_TYPE_TAG -> {
                return ValueCreator.createRecordValue(expectedType.getPackage(), expectedType.getName());
            }
            case TypeTags.MAP_TAG -> {
                return ValueCreator.createMapValue((MapType) expectedType);
            }
            case TypeTags.JSON_TAG -> {
                return ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);
            }
            case TypeTags.ANYDATA_TAG -> {
                return ValueCreator.createMapValue(Constants.ANYDATA_MAP_TYPE);
            }
            case TypeTags.UNION_TAG -> {
                sm.parserContexts.push(JsonParser.StateMachine.ParserContext.MAP);
                sm.unionDepth++;
                sm.fieldNameHierarchy.push(new Stack<>());
                return ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);
            }
            default -> throw DiagnosticLog.error(DiagnosticErrorCode.INVALID_TYPE, expectedType, "map type");
        }
    }

    static BArray initArrayValue(JsonParser.StateMachine sm, Type expectedType) {
        switch (expectedType.getTag()) {
            case TypeTags.TUPLE_TAG -> {
                return ValueCreator.createTupleValue((TupleType) expectedType);
            }
            case TypeTags.ARRAY_TAG -> {
                return ValueCreator.createArrayValue((ArrayType) expectedType);
            }
            case TypeTags.JSON_TAG -> {
                return ValueCreator.createArrayValue(PredefinedTypes.TYPE_JSON_ARRAY);
            }
            case TypeTags.ANYDATA_TAG -> {
                return ValueCreator.createArrayValue(PredefinedTypes.TYPE_ANYDATA_ARRAY);
            }
            case TypeTags.UNION_TAG -> {
                sm.unionDepth++;
                sm.arrayIndexes.push(0);
                return ValueCreator.createArrayValue(PredefinedTypes.TYPE_JSON_ARRAY);
            }
            default -> throw DiagnosticLog.error(DiagnosticErrorCode.INVALID_TYPE, expectedType, "list type");
        }
    }

    static Optional<BMap<BString, Object>> initNewMapValue(JsonParser.StateMachine sm) {
        JsonParser.StateMachine.ParserContext parentContext = sm.parserContexts.peek();
        sm.parserContexts.push(JsonParser.StateMachine.ParserContext.MAP);
        Type expType = sm.expectedTypes.peek();
        if (expType == null) {
            sm.fieldNameHierarchy.push(new Stack<>());
            return Optional.empty();
        }

        if (sm.currentJsonNode != null) {
            sm.nodesStack.push(sm.currentJsonNode);
        }
        BMap<BString, Object> nextMapValue = checkTypeAndCreateMappingValue(sm, expType, parentContext);
        return Optional.of(nextMapValue);
    }

    static BMap<BString, Object> checkTypeAndCreateMappingValue(JsonParser.StateMachine sm, Type expType,
                                                                JsonParser.StateMachine.ParserContext parentContext) {
        Type currentType = TypeUtils.getReferredType(expType);
        BMap<BString, Object> nextMapValue;
        switch (currentType.getTag()) {
            case TypeTags.RECORD_TYPE_TAG -> {
                RecordType recordType = (RecordType) currentType;
                nextMapValue = ValueCreator.createRecordValue(expType.getPackage(), expType.getName());
                sm.updateExpectedType(getAllFieldsInRecord(recordType), recordType.getRestFieldType());
            }
            case TypeTags.MAP_TAG -> {
                nextMapValue = ValueCreator.createMapValue((MapType) currentType);
                sm.updateExpectedType(new HashMap<>(), ((MapType) currentType).getConstrainedType());
            }
            case TypeTags.JSON_TAG -> {
                nextMapValue = ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);
                sm.updateExpectedType(new HashMap<>(), currentType);
            }
            case TypeTags.ANYDATA_TAG -> {
                nextMapValue = ValueCreator.createMapValue(Constants.ANYDATA_MAP_TYPE);
                sm.updateExpectedType(new HashMap<>(), currentType);
            }
            case TypeTags.INTERSECTION_TAG -> {
                Optional<Type> mutableType = getMutableType((IntersectionType) currentType);
                if (mutableType.isEmpty()) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.INVALID_TYPE, currentType, "map type");
                }
                return checkTypeAndCreateMappingValue(sm, mutableType.get(), parentContext);
            }
            case TypeTags.UNION_TAG -> {
                nextMapValue = ValueCreator.createMapValue(Constants.JSON_MAP_TYPE);
                sm.parserContexts.push(JsonParser.StateMachine.ParserContext.MAP);
                sm.unionDepth++;
                sm.fieldNameHierarchy.push(new Stack<>());
            }
            default -> {
                if (parentContext == JsonParser.StateMachine.ParserContext.ARRAY) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.INVALID_TYPE, currentType, "map type");
                }
                throw DiagnosticLog.error(DiagnosticErrorCode.INVALID_TYPE_FOR_FIELD, getCurrentFieldPath(sm));
            }
        }
        return nextMapValue;
    }

    static void updateNextMapValue(JsonParser.StateMachine sm) {
        Optional<BMap<BString, Object>> nextMap = initNewMapValue(sm);
        if (nextMap.isPresent()) {
            sm.currentJsonNode = nextMap.get();
        } else {
            // This will restrict from checking the fieldHierarchy.
            sm.jsonFieldDepth++;
        }
    }

    static Optional<BArray> initNewArrayValue(JsonParser.StateMachine sm) {
        sm.parserContexts.push(JsonParser.StateMachine.ParserContext.ARRAY);
        if (sm.expectedTypes.peek() == null) {
            return Optional.empty();
        }

        Object currentJsonNode = sm.currentJsonNode;
        Type expType = TypeUtils.getReferredType(sm.expectedTypes.peek());
        if (expType.getTag() == TypeTags.INTERSECTION_TAG) {
            Optional<Type> type = getMutableType((IntersectionType) expType);
            if (type.isEmpty()) {
                throw DiagnosticLog.error(DiagnosticErrorCode.INVALID_TYPE, expType, "array type");
            }
            expType = type.get();
        }
        BArray nextArrValue = initArrayValue(sm, expType);
        if (currentJsonNode == null) {
            return Optional.ofNullable(nextArrValue);
        }

        sm.nodesStack.push(currentJsonNode);
        return Optional.ofNullable(nextArrValue);
    }

    static Optional<Type> getMutableType(IntersectionType intersectionType) {
        for (Type constituentType : intersectionType.getConstituentTypes()) {
            if (constituentType.getTag() == TypeTags.READONLY_TAG) {
                continue;
            }
            return Optional.of(constituentType);
        }
        return Optional.empty();
    }

    private static String getCurrentFieldPath(JsonParser.StateMachine sm) {
        Iterator<Stack<String>> itr = sm.fieldNameHierarchy.iterator();
        StringBuilder result = new StringBuilder(itr.hasNext() ? itr.next().peek() : "");
        while (itr.hasNext()) {
            result.append(".").append(itr.next().peek());
        }
        return result.toString();
    }

    @SuppressWarnings("unchecked")
    static Object convertAndUpdateCurrentJsonNode(JsonParser.StateMachine sm, String value, Type type,
                                                  boolean isStringElement) {
        Object currentJson = sm.currentJsonNode;
        if (sm.nilAsOptionalField && !type.isNilable() && value.equals(Constants.NULL_VALUE)
                && sm.currentField != null && SymbolFlags.isFlagOn(sm.currentField.getFlags(), SymbolFlags.OPTIONAL)) {
                return null;
        }

        Object convertedValue = isStringElement ? convertStringToExpectedType(StringUtils.fromString(value), type) :
                validateNonStringValueAndConvertToExpectedType(value, type);
        if (convertedValue instanceof BError) {
            if (sm.currentField != null) {
                throw DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_VALUE_FOR_FIELD, value, type,
                        getCurrentFieldPath(sm));
            }
            throw DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE, type, value);
        }

        Type currentJsonNodeType = TypeUtils.getType(currentJson);
        switch (currentJsonNodeType.getTag()) {
            case TypeTags.MAP_TAG, TypeTags.RECORD_TYPE_TAG ->
                ((BMap<BString, Object>) currentJson).put(StringUtils.fromString(sm.fieldNameHierarchy.peek().pop()),
                        convertedValue);
            case TypeTags.ARRAY_TAG -> {
                // Handle projection in array.
                ArrayType arrayType = (ArrayType) currentJsonNodeType;
                if (arrayType.getState() != ArrayType.ArrayState.CLOSED ||
                        arrayType.getSize() > sm.arrayIndexes.peek()) {
                    ((BArray) currentJson).add(sm.arrayIndexes.peek(), convertedValue);
                }
            }
            case TypeTags.TUPLE_TAG ->
                ((BArray) currentJson).add(sm.arrayIndexes.peek(), convertedValue);
            default -> {
                return convertedValue;
            }
        }
        return currentJson;
    }

    static void checkNullAndUpdateCurrentJson(JsonParser.StateMachine sm, Object value) {
        if (value == null) {
            return;
        }
        sm.currentJsonNode = value;
    }

    private static Object convertStringToExpectedType(BString value, Type type) {
        switch (type.getTag()) {
            case TypeTags.STRING_TAG, TypeTags.ANYDATA_TAG, TypeTags.JSON_TAG -> {
                return value;
            }
            case TypeTags.CHAR_STRING_TAG -> {
                if (value.length() != 1) {
                    return DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE, type, value);
                }
                return value;
            }
            case TypeTags.FINITE_TYPE_TAG -> {
                return ((FiniteType) type).getValueSpace().stream()
                        .filter(finiteValue -> !(convertToSingletonValue(value.getValue(), finiteValue, true)
                                instanceof BError))
                        .findFirst()
                        .orElseGet(() -> DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE, type, value));
            }
            case TypeTags.UNION_TAG -> {
                for (Type memberType : ((UnionType) type).getMemberTypes()) {
                    Object convertedValue = convertStringToExpectedType(value, memberType);
                    if (!(convertedValue instanceof BError)) {
                        return convertedValue;
                    }
                }
                return DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE, type, value);
            }
            case TypeTags.TYPE_REFERENCED_TYPE_TAG -> {
                return convertStringToExpectedType(value, TypeUtils.getReferredType(type));
            }
            default -> {
                return DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE, type, value);
            }
        }
    }

    private static Object validateNonStringValueAndConvertToExpectedType(String value, Type type) {
        char ch = value.charAt(0);
        if (ch == 't') {
            if (!Constants.TRUE.equals(value)) {
                throw DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE, type, value);
            }
        } else if (ch == 'f') {
            if (!Constants.FALSE.equals(value)) {
                throw DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE, type, value);
            }
        } else if (ch == 'n') {
            if (!Constants.NULL_VALUE.equals(value)) {
                throw DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE, type, value);
            }
        } else if (!(Character.isDigit(ch) || ch == '-' || ch == '+')) {
            throw DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE, type, value);
        }

        return convertNonStringToExpectedType(StringUtils.fromString(value), type);
    }

    private static Object convertNonStringToExpectedType(BString value, Type type) {
        switch (type.getTag()) {
            case TypeTags.ANYDATA_TAG, TypeTags.JSON_TAG -> {
                return FromString.fromStringWithType(value, UNION_OF_BASIC_TYPE_WITHOUT_STRING);
            }
            case TypeTags.STRING_TAG, TypeTags.CHAR_STRING_TAG -> {
                return DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE, type, value);
            }
            case TypeTags.FINITE_TYPE_TAG -> {
                return ((FiniteType) type).getValueSpace().stream()
                        .filter(finiteValue -> !(convertToSingletonValue(value.getValue(),
                                finiteValue, false) instanceof BError))
                        .findFirst()
                        .orElseGet(() -> DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE, type, value));
            }
            case TypeTags.UNION_TAG -> {
                List<Type> newMembers = new ArrayList<>();
                for (Type memberType : ((UnionType) type).getMemberTypes()) {
                    int typeTag = memberType.getTag();
                    if (typeTag == TypeTags.STRING_TAG) {
                        continue;
                    }

                    if (typeTag == TypeTags.JSON_TAG || typeTag == TypeTags.ANYDATA_TAG) {
                        newMembers.add(UNION_OF_BASIC_TYPE_WITHOUT_STRING);
                    } else {
                        newMembers.add(memberType);
                    }
                }
                return FromString.fromStringWithType(value, TypeCreator.createUnionType(newMembers));
            }
            case TypeTags.TYPE_REFERENCED_TYPE_TAG -> {
                return convertNonStringToExpectedType(value, TypeUtils.getReferredType(type));
            }
            default -> {
                return FromString.fromStringWithType(value, type);
            }
        }
    }

    private static Object convertToSingletonValue(String str, Object singletonValue, boolean isStringElement) {
        String singletonStr = String.valueOf(singletonValue);
        if (str.equals(singletonStr)) {
            BString value = StringUtils.fromString(str);
            Type expType = TypeUtils.getType(singletonValue);
            return isStringElement ?
                    convertStringToExpectedType(value, expType) : convertNonStringToExpectedType(value, expType);
        } else {
            return DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE, singletonValue, str);
        }
    }

    static Type getMemberType(Type expectedType, int index, boolean allowDataProjection) {
        if (expectedType == null) {
            return null;
        }

        if (expectedType.getTag() == TypeTags.ARRAY_TAG) {
            ArrayType arrayType = (ArrayType) expectedType;
            if (arrayType.getState() == ArrayType.ArrayState.OPEN
                    || arrayType.getState() == ArrayType.ArrayState.CLOSED &&  index < arrayType.getSize()) {
                return arrayType.getElementType();
            }

            if (!allowDataProjection) {
                throw DiagnosticLog.error(DiagnosticErrorCode.ARRAY_SIZE_MISMATCH);
            }
            return null;
        } else if (expectedType.getTag() == TypeTags.TUPLE_TAG) {
            TupleType tupleType = (TupleType) expectedType;
            List<Type> tupleTypes = tupleType.getTupleTypes();
            if (tupleTypes.size() < index + 1) {
                Type restType = tupleType.getRestType();
                if (restType == null && !allowDataProjection) {
                    throw DiagnosticLog.error(DiagnosticErrorCode.ARRAY_SIZE_MISMATCH);
                }
                return restType;
            }
            return tupleTypes.get(index);
        }
        return expectedType;
    }

    @SuppressWarnings("unchecked")
    static Map<String, Field> getAllFieldsInRecord(RecordType recordType) {
        BMap<BString, Object> annotations = recordType.getAnnotations();
        Map<String, String> modifiedNames = new HashMap<>();
        for (BString annotationKey : annotations.getKeys()) {
            String keyStr = annotationKey.getValue();
            if (!keyStr.contains(Constants.FIELD)) {
                continue;
            }
            String fieldName = keyStr.split(Constants.FIELD_REGEX)[1];
            Map<BString, Object> fieldAnnotation = (Map<BString, Object>) annotations.get(annotationKey);
            modifiedNames.put(fieldName, getModifiedName(fieldAnnotation, fieldName));
        }

        Map<String, Field> fields = new HashMap<>();
        Map<String, Field> recordFields = recordType.getFields();
        for (String key : recordFields.keySet()) {
            String fieldName = modifiedNames.getOrDefault(key, key);
            if (fields.containsKey(fieldName)) {
                throw DiagnosticLog.error(DiagnosticErrorCode.DUPLICATE_FIELD, fieldName);
            }
            fields.put(fieldName, recordFields.get(key));
        }
        return fields;
    }

    @SuppressWarnings("unchecked")
    static String getModifiedName(Map<BString, Object> fieldAnnotation, String fieldName) {
        for (BString key : fieldAnnotation.keySet()) {
            if (key.getValue().endsWith(Constants.NAME)) {
                return ((Map<BString, Object>) fieldAnnotation.get(key)).get(Constants.VALUE).toString();
            }
        }
        return fieldName;
    }

    static Object constructReadOnlyValue(Object value) {
        return CloneReadOnly.cloneReadOnly(value);
    }

    static Object initRootArrayValue(JsonParser.StateMachine sm) {
        sm.parserContexts.push(JsonParser.StateMachine.ParserContext.ARRAY);
        Type expType = sm.expectedTypes.peek();
        // In this point we know rhs is json[] or anydata[] hence init index counter.
        if (expType.getTag() == TypeTags.JSON_TAG || expType.getTag() == TypeTags.ANYDATA_TAG) {
            sm.arrayIndexes.push(0);
        }
        return initArrayValue(sm, expType);
    }

    static void updateExpectedType(JsonParser.StateMachine sm) {
        if (sm.unionDepth > 0) {
            return;
        }
        sm.expectedTypes.push(JsonCreator.getMemberType(sm.expectedTypes.peek(),
                sm.arrayIndexes.peek(), sm.allowDataProjection));
    }

    static void updateNextMapValueBasedOnExpType(JsonParser.StateMachine sm) {
        updateExpectedType(sm);
        updateNextMapValue(sm);
    }

    static void updateNextArrayValueBasedOnExpType(JsonParser.StateMachine sm) {
        updateExpectedType(sm);
        updateNextArrayValue(sm);
    }

    static void handleFieldName(String jsonFieldName, JsonParser.StateMachine sm) {
        if (sm.jsonFieldDepth == 0 && sm.unionDepth == 0) {
            Field currentField = sm.visitedFieldHierarchy.peek().get(jsonFieldName);
            if (currentField == null) {
                currentField = sm.fieldHierarchy.peek().remove(jsonFieldName);
            }
            sm.currentField = currentField;

            Type fieldType;
            if (currentField == null) {
                fieldType = sm.restType.peek();
            } else {
                // Replace modified field name with actual field name.
                jsonFieldName = currentField.getFieldName();
                fieldType = currentField.getFieldType();
                sm.visitedFieldHierarchy.peek().put(jsonFieldName, currentField);
            }
            sm.expectedTypes.push(fieldType);

            if (!sm.allowDataProjection && fieldType == null)  {
                throw DiagnosticLog.error(DiagnosticErrorCode.UNDEFINED_FIELD, jsonFieldName);
            }
        } else if (sm.expectedTypes.peek() == null) {
            sm.expectedTypes.push(null);
        }
        sm.fieldNameHierarchy.peek().push(jsonFieldName);
    }

    static void updateNextArrayValue(JsonParser.StateMachine sm) {
        sm.arrayIndexes.push(0);
        Optional<BArray> nextArray = JsonCreator.initNewArrayValue(sm);
        nextArray.ifPresent(bArray -> sm.currentJsonNode = bArray);
    }
}
