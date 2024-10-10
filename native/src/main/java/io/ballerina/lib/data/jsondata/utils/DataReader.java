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

package io.ballerina.lib.data.jsondata.utils;

import io.ballerina.runtime.api.types.MethodType;
import io.ballerina.runtime.api.types.ObjectType;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BObject;

/**
 * A class that holds util methods needed for BallerinaByteBlockInputStream class.
 *
 * @since 2.5.0
 */
public class DataReader {

    private static final String METHOD_NAME_NEXT = "next";
    private static final String METHOD_NAME_CLOSE = "close";

    public static MethodType resolveNextMethod(BObject iterator) {
        MethodType method = getMethodType(iterator, METHOD_NAME_NEXT);
        if (method != null) {
            return method;
        }
        throw new IllegalStateException("next method not found in the iterator object");
    }

    public static MethodType resolveCloseMethod(BObject iterator) {
        return getMethodType(iterator, METHOD_NAME_CLOSE);
    }

    public static MethodType getMethodType(BObject iterator, String methodName) {
        ObjectType objectType = (ObjectType) TypeUtils.getReferredType(iterator.getOriginalType());
        MethodType[] methods = objectType.getMethods();
        // Assumes compile-time validation of the iterator object
        for (MethodType method : methods) {
            if (method.getName().equals(methodName)) {
                return method;
            }
        }
        return null;
    }
}
