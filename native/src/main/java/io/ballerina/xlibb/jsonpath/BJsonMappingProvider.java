/*
 * Copyright (c) 2024 WSO2 LLC. (http://www.wso2.com) All Rights Reserved.
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.xlibb.jsonpath;

import com.jayway.jsonpath.Configuration;
import com.jayway.jsonpath.TypeRef;
import com.jayway.jsonpath.spi.mapper.JakartaMappingProvider;
import com.jayway.jsonpath.spi.mapper.MappingException;
import com.jayway.jsonpath.spi.mapper.MappingProvider;
import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.TypeTags;
import io.ballerina.runtime.api.utils.JsonUtils;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import org.wso2.ballerinalang.compiler.semantics.model.types.BMapType;
import org.wso2.ballerinalang.compiler.semantics.model.types.BType;

import java.lang.reflect.Constructor;
import java.lang.reflect.GenericArrayType;
import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.Collection;
import java.util.List;
import java.util.Queue;
import java.util.Set;

/**
 * Provides Ballerina specific convert operations of json-path.
 */
public class BJsonMappingProvider implements MappingProvider {
    /**
     * @param source        object to map
     * @param targetType    the type the source object should be mapped to
     * @param configuration current configuration
     * @return return the mapped object
     */
    @Override
    public <T> T map(Object source, Class<T> targetType, Configuration configuration) {
        if (source == null) {
            return null;
        }
        try {
            T result = (T) mapImpl(source, targetType);
            return result;
        } catch (Exception e) {
            throw new MappingException(e);
        }
    }

    /**
     * @param source        object to map
     * @param targetType    the type the source object should be mapped to
     * @param configuration current configuration
     * @return return the mapped object
     */
    @Override
    public <T> T map(Object source, TypeRef<T> targetType, Configuration configuration) {
        T result = (T) mapImpl(source, targetType.getType());
        return result;
    }

    private Object mapImpl(Object source, final Type targetType) {
        String className = targetType.toString();
        if (source == null) {
            return null;
        }
        if (source instanceof Boolean) {
            if (Boolean.class.equals(targetType)) {
                return JsonUtils.convertJSON(source, PredefinedTypes.TYPE_BOOLEAN);
            } else {
                throw new MappingException("JSON boolean cannot be mapped to " + className);
            }
        } else if (source instanceof String) {
            if (String.class.equals(targetType)) {
                return JsonUtils.convertJSON(source, PredefinedTypes.TYPE_STRING);
            } else {
                throw new MappingException("JSON String cannot be mapped to " + className);
            }
        } else if (source instanceof BString) {
            if (String.class.equals(targetType)) {
                return StringUtils.fromString(JsonUtils.convertJSON(source, PredefinedTypes.TYPE_STRING).toString());
            } else {
                throw new MappingException("JSON String cannot be mapped to " + className);
            }
        } else if (isJsonIntegral(source)) {
            return mapIntegralJsonNumber(source, getRawClass(targetType));
        } else if (isJsonDecimal(source)) {
            return mapIntegralJsonNumber(source, getRawClass(targetType));
        } else if (source instanceof Collection) {
            Class<?> rawTargetType = getRawClass(targetType);
            Type targetTypeArg = getFirstTypeArgument(targetType);
            Collection<Object> result = newCollectionOfType(rawTargetType);
            for (Object srcValue : (Collection<?>) source) {
                if (srcValue instanceof BMap) {
                    if (targetTypeArg != null) {
                        result.add(mapImpl(srcValue, targetTypeArg));
                    } else {
                        result.add(srcValue);
                    }
                } else {
                    result.add(unwrapJsonValue(srcValue));
                }
            }
            return result;
        } else if (source instanceof BMap) {
            try {
                return JsonUtils.convertJSON(source, (io.ballerina.runtime.api.types.Type) targetType);
            } catch (Exception ex) {
                throw new MappingException("JSON object cannot be databind to " + targetType);
            }
        } else {
            return source;
        }
    }

    private Object unwrapJsonValue(Object obj) {
        if (obj == null) {
            return null;
        }
        return JsonUtils.convertJSON(obj, TypeUtils.getType(obj));
    }

    private io.ballerina.runtime.api.types.Type getTargetType(Class<?> targetType) {
        if (BMap.class.equals(targetType)) {
            return PredefinedTypes.TYPE_MAP;
        } else if (BArray.class.equals(targetType)) {
            return PredefinedTypes.TYPE_JSON_ARRAY;
        } else if (BString.class.equals(targetType)) {
            return PredefinedTypes.TYPE_STRING;
        } else if (String.class.equals(targetType)) {
            return PredefinedTypes.TYPE_STRING;
        } else if (Boolean.class.equals(targetType)) {
            return PredefinedTypes.TYPE_BOOLEAN;
        } else if (isJsonIntegral(targetType)) {
            return PredefinedTypes.TYPE_INT;
        } else if (Double.class.equals(targetType) || Float.class.equals(targetType)) {
            return PredefinedTypes.TYPE_FLOAT;
        } else if (BigDecimal.class.equals(targetType) ) {
            return PredefinedTypes.TYPE_DECIMAL;
        } else {
            return PredefinedTypes.TYPE_ANY;
        }
    }

    private Type getFirstTypeArgument(Type targetType) {
        if (targetType instanceof ParameterizedType) {
            Type[] args = ((ParameterizedType) targetType).getActualTypeArguments();
            if (args != null && args.length > 0) {
                if (args[0] instanceof Class) {
                    return args[0];
                } else if (args[0] instanceof ParameterizedType) {
                    return args[0];
                }
            }
        }
        return null;
    }

    private Collection<Object> newCollectionOfType(Class<?> collectionType) throws MappingException {
        if (Collection.class.isAssignableFrom(collectionType)) {
            if (!collectionType.isInterface()) {
                @SuppressWarnings("unchecked")
                Collection<Object> coll = (Collection<Object>) newNoArgInstance(collectionType);
                return coll;
            } else if (List.class.isAssignableFrom(collectionType)) {
                return new java.util.LinkedList<>();
            } else if (Set.class.isAssignableFrom(collectionType)) {
                return new java.util.LinkedHashSet<>();
            } else if (Queue.class.isAssignableFrom(collectionType)) {
                return new java.util.LinkedList<>();
            }
        }
        String className = collectionType.getSimpleName();
        throw new MappingException("JSON array cannot be mapped to " + className);
    }

    private Object newNoArgInstance(Class<?> targetType) throws MappingException {
        if (targetType.isInterface()) {
            return null;
        } else {
            for (Constructor<?> ctr : targetType.getConstructors()) {
                if (ctr.getParameterCount() == 0) {
                    try {
                        return ctr.newInstance();
                    } catch (ReflectiveOperationException e) {
                        throw new MappingException(e);
                    } catch (IllegalArgumentException e) {
                        // never happens
                    }
                }
            }
            String className = targetType.getSimpleName();
            throw new MappingException("Unable to find no-arg ctr for " + className);
        }
    }

    private <T> T mapIntegralJsonNumber(Object source, Class<?> targetType) {
        if (targetType.isPrimitive()) {
            if (int.class.equals(targetType)) {
                return (T) Integer.valueOf((int) source);
            } else if (long.class.equals(targetType)) {
                return (T) Long.valueOf((long) source);
            }
        } else if (Integer.class.equals(targetType)) {
            return (T) Integer.valueOf((int) source);
        } else if (Long.class.equals(targetType)) {
            return (T) Long.valueOf((long) source);
        } else if (BigInteger.class.equals(targetType)) {
            return (T) BigInteger.valueOf((long) source);
        } else if (BigDecimal.class.equals(targetType)) {
            return (T) BigDecimal.valueOf((double) source);
        }

        String className = targetType.getSimpleName();
        throw new MappingException("JSON integral number cannot be mapped to " + className);
    }

    private <T> T mapDecimalJsonNumber(Object source, Class<?> targetType) {
        if (targetType.isPrimitive()) {
            if (float.class.equals(targetType)) {
                return (T) new Float((float) source);
            } else if (double.class.equals(targetType)) {
                return (T) Double.valueOf((double) source);
            }
        } else if (Float.class.equals(targetType)) {
            return (T) new Float((float) source);
        } else if (Double.class.equals(targetType)) {
            return (T) Double.valueOf((double) source);
        } else if (BigDecimal.class.equals(targetType)) {
            return (T) BigDecimal.valueOf((double) source);
        }

        String className = targetType.getSimpleName();
        throw new MappingException("JSON decimal number cannot be mapped to " + className);
    }

    private boolean isJsonIntegral(Object source) {
        return source instanceof Integer ||
                source instanceof BigInteger ||
                source instanceof Long ||
                source instanceof BigDecimal;
    }

    private boolean isJsonDecimal(Object source) {
        return source instanceof Double ||
                source instanceof Float ||
                source instanceof BigDecimal;
    }

    private Class<?> getRawClass(Type targetType) {
        if (targetType instanceof Class) {
            return (Class<?>) targetType;
        } else if (targetType instanceof ParameterizedType) {
            return (Class<?>) ((ParameterizedType) targetType).getRawType();
        } else if (targetType instanceof GenericArrayType) {
            String typeName = targetType.getTypeName();
            throw new MappingException("Cannot map JSON element to " + typeName);
        } else {
            String typeName = targetType.getTypeName();
            throw new IllegalArgumentException("TypeRef not supported: " + typeName);
        }
    }
}
