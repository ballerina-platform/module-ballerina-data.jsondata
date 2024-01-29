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

package io.ballerina.stdlib.data.jsondata;

import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.TypeTags;
import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.ReferenceType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.UnionType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BDecimal;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

/**
 * Native implementation of data:fromStringWithType(string).
 *
 * @since 0.1.0
 */
public class FromString {

    public static Object fromStringWithType(BString string, BTypedesc typed) {
        Type expType = typed.getDescribingType();

        try {
            return fromStringWithType(string, expType);
        } catch (NumberFormatException e) {
            return returnError(string.getValue(), expType.toString());
        }
    }

    public static Object fromStringWithType(BString string, Type expType) {
        String value = string.getValue();
        try {
            switch (expType.getTag()) {
                case TypeTags.INT_TAG:
                    return stringToInt(value);
                case TypeTags.FLOAT_TAG:
                    return stringToFloat(value);
                case TypeTags.DECIMAL_TAG:
                    return stringToDecimal(value);
                case TypeTags.STRING_TAG:
                    return string;
                case TypeTags.BOOLEAN_TAG:
                    return stringToBoolean(value);
                case TypeTags.NULL_TAG:
                    return stringToNull(value);
                case TypeTags.UNION_TAG:
                    return stringToUnion(string, (UnionType) expType);
                case TypeTags.JSON_TAG:
                    return stringToJson(string);
                case TypeTags.TYPE_REFERENCED_TYPE_TAG:
                    return fromStringWithType(string, ((ReferenceType) expType).getReferredType());
                default:
                    return returnError(value, expType.toString());
            }
        } catch (NumberFormatException e) {
            return returnError(value, expType.toString());
        }
    }

    private static Long stringToInt(String value) throws NumberFormatException {
        return Long.parseLong(value);
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
        List<Type> memberTypes = expType.getMemberTypes();
        memberTypes.sort(Comparator.comparingInt(t -> t.getTag()));
        boolean isStringExpType = false;
        for (Type memberType : memberTypes) {
            try {
                Object result = fromStringWithType(string, memberType);
                if (result instanceof BString) {
                    isStringExpType = true;
                    continue;
                } else if (result instanceof BError) {
                    continue;
                }
                return result;
            } catch (Exception e) {
                // Skip
            }
        }

        if (isStringExpType) {
            return string;
        }
        return returnError(string.getValue(), expType.toString());
    }

    private static Object stringToJson(BString string) {
        ArrayList<Type> jsonMembers = new ArrayList<>();
        jsonMembers.add(PredefinedTypes.TYPE_NULL);
        jsonMembers.add(PredefinedTypes.TYPE_BOOLEAN);
        jsonMembers.add(PredefinedTypes.TYPE_INT);
        jsonMembers.add(PredefinedTypes.TYPE_FLOAT);
        jsonMembers.add(PredefinedTypes.TYPE_DECIMAL);
        jsonMembers.add(PredefinedTypes.TYPE_STRING);

        UnionType jsonType = TypeCreator.createUnionType(jsonMembers);
        return stringToUnion(string, jsonType);
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

    private static BError returnError(String string, String expType) {
        return ErrorCreator.createError(StringUtils.fromString("Cannot convert to the exptype"));
    }
}
