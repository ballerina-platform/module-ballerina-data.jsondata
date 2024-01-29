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

import com.jayway.jsonpath.InvalidJsonException;
import com.jayway.jsonpath.JsonPathException;
import com.jayway.jsonpath.spi.json.AbstractJsonProvider;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.JsonUtils;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.*;

import java.io.InputStream;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * Provides Ballerina specific function implementations of json-path.
 */
public class BJsonProvider extends AbstractJsonProvider {
    /**
     * Parse the given json string
     *
     * @param json json string to parse
     * @return Object representation of json
     * @throws InvalidJsonException
     */
    @Override
    public Object parse(String json) throws InvalidJsonException {
        return JsonUtils.parse(json);
    }

    /**
     * Parse the given json bytes in UTF-8 encoding
     *
     * @param json json bytes to parse
     * @return Object representation of json
     * @throws InvalidJsonException
     */
    @Override
    public Object parse(byte[] json) throws InvalidJsonException {
        return super.parse(json);
    }

    /**
     * Parse the given json string
     *
     * @param jsonStream input stream to parse
     * @param charset    charset to use
     * @return Object representation of json
     * @throws InvalidJsonException
     */
    @Override
    public Object parse(InputStream jsonStream, String charset) throws InvalidJsonException {
        return JsonUtils.parse(jsonStream, charset);
    }

    /**
     * Convert given json object to a json string
     *
     * @param obj object to transform
     * @return json representation of object
     */
    @Override
    public String toJson(Object obj) {
        return StringUtils.getJsonString(obj);
    }

    /**
     * Creates a provider specific json array
     *
     * @return new array
     */
    @Override
    public Object createArray() {
        return ValueCreator.createArrayValue(PredefinedTypes.TYPE_JSON_ARRAY);
    }

    /**
     * Creates a provider specific json object
     *
     * @return new object
     */
    @Override
    public Object createMap() {
        return ValueCreator.createMapValue();
    }

    public boolean isArray(Object obj) {
        return (obj instanceof BArray);
    }

    public Object getArrayIndex(Object obj, int idx) {
        return toJsonArray(obj).get(idx);
    }

    public void setArrayIndex(Object array, int index, Object newValue) {
        if (!isArray(array)) {
            throw new UnsupportedOperationException();
        } else {
            BArray arrayNode = toJsonArray(array);
            if (index == arrayNode.size()) {
                arrayNode.append(createJsonElement(newValue));
            } else {
                arrayNode.add(index, createJsonElement(newValue));
            }
        }
    }

    public Object getMapValue(Object obj, String key) {
        if (!(obj instanceof BMap)) {
            throw new UnsupportedOperationException();
        } else {
            BMap jsonObject = toJsonObject(obj);
            if (!jsonObject.containsKey(StringUtils.fromString(key))) {
                return UNDEFINED;
            } else {
                return unwrap(jsonObject.get(StringUtils.fromString(key)));
            }
        }
    }

    public void setProperty(Object obj, Object key, Object value) {
        if (isMap(obj)) {
            toJsonObject(obj).put(key.toString(), createJsonElement(value));
        } else {
            BArray array = toJsonArray(obj);
            long index;
            if (key != null) {
                index = key instanceof Integer ? (Integer) key : Integer.parseInt(key.toString());
            } else {
                index = array.size();
            }

            if (index == array.size()) {
                array.append(createJsonElement(value));
            } else {
                array.add(index, createJsonElement(value));
            }
        }
    }

    public void removeProperty(Object obj, Object key) {
        if (isMap(obj)) {
            toJsonObject(obj).remove(key.toString());
        } else {
            BArray array = toJsonArray(obj);
            int index = key instanceof Integer ? (Integer) key : Integer.parseInt(key.toString());
            array.shift(index);
        }
    }

    public boolean isMap(Object obj) {
        return (obj instanceof BMap);
    }

    public Collection<String> getPropertyKeys(Object obj) {
        List<String> keys = new ArrayList<>();
        for (Object entry : toJsonObject(obj).getKeys()) {
            keys.add(entry.toString());
        }
        return keys;
    }

    public int length(Object obj) {
        if (isArray(obj)) {
            return toJsonArray(obj).size();
        } else if (isMap(obj)) {
            return toJsonObject(obj).entrySet().size();
        } else {
            if (isJsonPrimitive(obj)) {
                return obj.toString().length();
            }
        }
        throw new JsonPathException("length operation can not applied to " + (obj != null ? obj.getClass().getName()
                : "null"));
    }

    public Iterable<?> toIterable(Object obj) {
        BArray arr = toJsonArray(obj);
        List<Object> values = new ArrayList<>(arr.size());
        for (int i = 0; i < arr.size(); i++) {
            values.add(unwrap(arr.get(i)));
        }
        return values;
    }

    public Object unwrap(Object obj) {
        if (obj == null) {
            return null;
        }
        Type targetType;
        if (isMap(obj)) {
            targetType = PredefinedTypes.TYPE_MAP;
        } else if (isArray(obj)) {
            targetType = PredefinedTypes.TYPE_JSON_ARRAY;
        } else if (obj instanceof BString) {
            obj = StringUtils.getStringValue(obj);
            targetType = PredefinedTypes.TYPE_STRING;
        } else if (obj instanceof BDecimal) {
            targetType = PredefinedTypes.TYPE_FLOAT;
        } else if (obj instanceof String) {
            targetType = PredefinedTypes.TYPE_STRING;
        } else if (obj instanceof Boolean) {
            targetType = PredefinedTypes.TYPE_BOOLEAN;
        } else if (obj instanceof Long) {
            targetType = PredefinedTypes.TYPE_INT;
        } else if (obj instanceof Integer) {
            obj = ((Integer) obj).longValue();
            targetType = PredefinedTypes.TYPE_INT;
        } else if (obj instanceof BigDecimal) {
            targetType = PredefinedTypes.TYPE_JSON_DECIMAL;
        } else if (obj instanceof Double) {
            targetType = PredefinedTypes.TYPE_JSON_FLOAT;
        } else {
            targetType = PredefinedTypes.TYPE_ANY;
        }
        return JsonUtils.convertJSON(obj, targetType);
    }

    private boolean isJsonPrimitive(Object obj) {
        return obj == null ||
                obj instanceof Long ||
                obj instanceof Integer ||
                obj instanceof BigDecimal ||
                obj instanceof Double ||
                obj instanceof BString ||
                obj instanceof String ||
                obj instanceof Boolean;
    }

    private Object createJsonElement(final Object o) {
        if (o instanceof String) {
            return JsonUtils.convertToJson(StringUtils.fromString((String) o));
        } else if (o instanceof List<?>) {
            BArray jsonArray = (BArray) createArray();
            for (Object element: ((List) o)) {
                jsonArray.append(createJsonElement(element));
            }
            return JsonUtils.convertToJson(jsonArray);
        }
        return JsonUtils.convertToJson(o);
    }

    private BArray toJsonArray(final Object o) {
        return (BArray) o;
    }

    private BMap toJsonObject(final Object o) {
        return (BMap) o;
    }
}
