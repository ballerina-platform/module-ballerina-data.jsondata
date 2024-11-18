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

package io.ballerina.lib.data.jsondata;

import io.ballerina.lib.data.jsondata.utils.DiagnosticErrorCode;
import io.ballerina.lib.data.jsondata.utils.DiagnosticLog;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.FiniteType;
import io.ballerina.runtime.api.types.IntersectionType;
import io.ballerina.runtime.api.types.PredefinedTypes;
import io.ballerina.runtime.api.types.ReferenceType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.TypeTags;
import io.ballerina.runtime.api.types.UnionType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BDecimal;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BString;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

/**
 * Native implementation of data:fromStringWithType(string).
 *
 * @since 0.1.0
 */
public class FromString {

    private static final List<Integer> TYPE_PRIORITY_ORDER = List.of(
        TypeTags.INT_TAG,
        TypeTags.FLOAT_TAG,
        TypeTags.DECIMAL_TAG,
        TypeTags.NULL_TAG,
        TypeTags.BOOLEAN_TAG,
        TypeTags.JSON_TAG,
        TypeTags.STRING_TAG
    );

    private static final List<Type> BASIC_JSON_MEMBER_TYPES = List.of(
        PredefinedTypes.TYPE_NULL,
        PredefinedTypes.TYPE_BOOLEAN,
        PredefinedTypes.TYPE_INT,
        PredefinedTypes.TYPE_FLOAT,
        PredefinedTypes.TYPE_DECIMAL,
        PredefinedTypes.TYPE_STRING
    );
    private static final UnionType JSON_TYPE_WITH_BASIC_TYPES = TypeCreator.createUnionType(BASIC_JSON_MEMBER_TYPES);
    public static final Integer BBYTE_MIN_VALUE = 0;
    public static final Integer BBYTE_MAX_VALUE = 255;
    public static final Integer SIGNED32_MAX_VALUE = 2147483647;
    public static final Integer SIGNED32_MIN_VALUE = -2147483648;
    public static final Integer SIGNED16_MAX_VALUE = 32767;
    public static final Integer SIGNED16_MIN_VALUE = -32768;
    public static final Integer SIGNED8_MAX_VALUE = 127;
    public static final Integer SIGNED8_MIN_VALUE = -128;
    public static final Long UNSIGNED32_MAX_VALUE = 4294967295L;
    public static final Integer UNSIGNED16_MAX_VALUE = 65535;
    public static final Integer UNSIGNED8_MAX_VALUE = 255;

    public static Object fromStringWithType(BString string, Type expType) {
        String value = string.getValue();
        try {
            switch (expType.getTag()) {
                case TypeTags.INT_TAG:
                    return stringToInt(value);
                case TypeTags.BYTE_TAG:
                    return stringToByte(value);
                case TypeTags.SIGNED8_INT_TAG:
                    return stringToSigned8Int(value);
                case TypeTags.SIGNED16_INT_TAG:
                    return stringToSigned16Int(value);
                case TypeTags.SIGNED32_INT_TAG:
                    return stringToSigned32Int(value);
                case TypeTags.UNSIGNED8_INT_TAG:
                    return stringToUnsigned8Int(value);
                case TypeTags.UNSIGNED16_INT_TAG:
                    return stringToUnsigned16Int(value);
                case TypeTags.UNSIGNED32_INT_TAG:
                    return stringToUnsigned32Int(value);
                case TypeTags.FLOAT_TAG:
                    return stringToFloat(value);
                case TypeTags.DECIMAL_TAG:
                    return stringToDecimal(value);
                case TypeTags.CHAR_STRING_TAG:
                    return stringToChar(value);
                case TypeTags.STRING_TAG:
                    return string;
                case TypeTags.BOOLEAN_TAG:
                    return stringToBoolean(value);
                case TypeTags.NULL_TAG:
                    return stringToNull(value);
                case TypeTags.FINITE_TYPE_TAG:
                    return stringToFiniteType(value, (FiniteType) expType);
                case TypeTags.UNION_TAG:
                    return stringToUnion(string, (UnionType) expType);
                case TypeTags.JSON_TAG:
                case TypeTags.ANYDATA_TAG:
                    return stringToUnion(string, JSON_TYPE_WITH_BASIC_TYPES);
                case TypeTags.TYPE_REFERENCED_TYPE_TAG:
                    return fromStringWithType(string, ((ReferenceType) expType).getReferredType());
                case TypeTags.INTERSECTION_TAG:
                    return fromStringWithType(string, ((IntersectionType) expType).getEffectiveType());
                default:
                    return returnError(value, expType.toString());
            }
        } catch (NumberFormatException e) {
            return returnError(value, expType.toString());
        }
    }

    private static Object stringToFiniteType(String value, FiniteType finiteType) {
        return finiteType.getValueSpace().stream()
                .filter(finiteValue -> !(convertToSingletonValue(value, finiteValue) instanceof BError))
                .findFirst()
                .orElseGet(() -> returnError(value, finiteType.toString()));
    }

    private static Object convertToSingletonValue(String str, Object singletonValue) {
        String singletonStr = String.valueOf(singletonValue);
        if (str.equals(singletonStr)) {
            return fromStringWithType(StringUtils.fromString(str), TypeUtils.getType(singletonValue));
        } else {
            return returnError(str, singletonStr);
        }
    }

    private static Long stringToInt(String value) throws NumberFormatException {
        return Long.parseLong(value);
    }

    private static int stringToByte(String value) throws NumberFormatException {
        int intValue = Integer.parseInt(value);
        if (!isByteLiteral(intValue)) {
            throw DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE, PredefinedTypes.TYPE_BYTE, value);
        }
        return intValue;
    }

    private static long stringToSigned8Int(String value) throws NumberFormatException {
        long intValue = Long.parseLong(value);
        if (!isSigned8LiteralValue(intValue)) {
            throw DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE, PredefinedTypes.TYPE_INT_SIGNED_8, value);
        }
        return intValue;
    }

    private static long stringToSigned16Int(String value) throws NumberFormatException {
        long intValue = Long.parseLong(value);
        if (!isSigned16LiteralValue(intValue)) {
            throw DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE, PredefinedTypes.TYPE_INT_SIGNED_16, value);
        }
        return intValue;
    }

    private static long stringToSigned32Int(String value) throws NumberFormatException {
        long intValue = Long.parseLong(value);
        if (!isSigned32LiteralValue(intValue)) {
            throw DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE, PredefinedTypes.TYPE_INT_SIGNED_32, value);
        }
        return intValue;
    }

    private static long stringToUnsigned8Int(String value) throws NumberFormatException {
        long intValue = Long.parseLong(value);
        if (!isUnsigned8LiteralValue(intValue)) {
            throw DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE,
                    PredefinedTypes.TYPE_INT_UNSIGNED_8, value);
        }
        return intValue;
    }

    private static long stringToUnsigned16Int(String value) throws NumberFormatException {
        long intValue = Long.parseLong(value);
        if (!isUnsigned16LiteralValue(intValue)) {
            throw DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE,
                    PredefinedTypes.TYPE_INT_UNSIGNED_16, value);
        }
        return intValue;
    }

    private static long stringToUnsigned32Int(String value) throws NumberFormatException {
        long intValue = Long.parseLong(value);
        if (!isUnsigned32LiteralValue(intValue)) {
            throw DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE,
                    PredefinedTypes.TYPE_INT_UNSIGNED_32, value);
        }
        return intValue;
    }

    private static BString stringToChar(String value) throws NumberFormatException {
        if (!isCharLiteralValue(value)) {
            throw DiagnosticLog.error(DiagnosticErrorCode.INCOMPATIBLE_TYPE,
                    PredefinedTypes.TYPE_STRING_CHAR, value);
        }
        return StringUtils.fromString(value);
    }

    private static Double stringToFloat(String value) throws NumberFormatException {
        if (hasFloatOrDecimalLiteralSuffix(value)) {
            throw new NumberFormatException();
        }
        return Double.parseDouble(value);
    }

    private static BDecimal stringToDecimal(String value) throws NumberFormatException {
        return ValueCreator.createDecimalValue(value);
    }

    private static Object stringToBoolean(String value) throws NumberFormatException {
        if ("true".equalsIgnoreCase(value) || "1".equalsIgnoreCase(value)) {
            return true;
        }

        if ("false".equalsIgnoreCase(value) || "0".equalsIgnoreCase(value)) {
            return false;
        }
        return returnError(value, "boolean");
    }

    private static Object stringToNull(String value) throws NumberFormatException {
        if ("null".equalsIgnoreCase(value) || "()".equalsIgnoreCase(value)) {
            return null;
        }
        return returnError(value, "()");
    }

    private static Object stringToUnion(BString string, UnionType expType) throws NumberFormatException {
        List<Type> memberTypes = new ArrayList<>(expType.getMemberTypes());
        memberTypes.sort(Comparator.comparingInt(t -> {
            int index = TYPE_PRIORITY_ORDER.indexOf(TypeUtils.getReferredType(t).getTag());
            return index == -1 ? Integer.MAX_VALUE : index;
        }));
        for (Type memberType : memberTypes) {
            try {
                Object result = fromStringWithType(string, memberType);
                if (result instanceof BError) {
                    continue;
                }
                return result;
            } catch (Exception e) {
                // Skip
            }
        }
        return returnError(string.getValue(), expType.toString());
    }

    private static boolean hasFloatOrDecimalLiteralSuffix(String value) {
        int length = value.length();
        if (length == 0) {
            return false;
        }

        switch (value.charAt(length - 1)) {
            case 'F':
            case 'f':
            case 'D':
            case 'd':
                return true;
            default:
                return false;
        }
    }

    private static boolean isByteLiteral(long longValue) {
        return (longValue >= BBYTE_MIN_VALUE && longValue <= BBYTE_MAX_VALUE);
    }

    private static boolean isSigned32LiteralValue(Long longObject) {
        return (longObject >= SIGNED32_MIN_VALUE && longObject <= SIGNED32_MAX_VALUE);
    }

    private static boolean isSigned16LiteralValue(Long longObject) {
        return (longObject.intValue() >= SIGNED16_MIN_VALUE && longObject.intValue() <= SIGNED16_MAX_VALUE);
    }

    private static boolean isSigned8LiteralValue(Long longObject) {
        return (longObject.intValue() >= SIGNED8_MIN_VALUE && longObject.intValue() <= SIGNED8_MAX_VALUE);
    }

    private static boolean isUnsigned32LiteralValue(Long longObject) {
        return (longObject >= 0 && longObject <= UNSIGNED32_MAX_VALUE);
    }

    private static boolean isUnsigned16LiteralValue(Long longObject) {
        return (longObject.intValue() >= 0 && longObject.intValue() <= UNSIGNED16_MAX_VALUE);
    }

    private static boolean isUnsigned8LiteralValue(Long longObject) {
        return (longObject.intValue() >= 0 && longObject.intValue() <= UNSIGNED8_MAX_VALUE);
    }

    private static boolean isCharLiteralValue(String value) {
        return value.codePoints().count() == 1;
    }

    private static BError returnError(String string, String expType) {
        return DiagnosticLog.error(DiagnosticErrorCode.CANNOT_CONVERT_TO_EXPECTED_TYPE,
                PredefinedTypes.TYPE_STRING.getName(), string, expType);
    }
}
