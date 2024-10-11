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

import io.ballerina.lib.data.jsondata.io.BallerinaByteBlockInputStream;
import io.ballerina.lib.data.jsondata.utils.Constants;
import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BStream;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;

import java.io.ByteArrayInputStream;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.util.Map;

import static io.ballerina.lib.data.jsondata.json.JsonCreator.getModifiedName;
import static io.ballerina.lib.data.jsondata.utils.DataUtils.unescapeIdentifier;
import static io.ballerina.lib.data.jsondata.utils.DataReader.resolveCloseMethod;
import static io.ballerina.lib.data.jsondata.utils.DataReader.resolveNextMethod;

/**
 * Json conversions.
 *
 * @since 0.1.0
 */
public class Native {

    public static Object parseAsType(Object json, BMap<BString, Object> options, BTypedesc typed) {
        try {
            return JsonTraverse.traverse(json, options, typed);
        } catch (BError e) {
            return e;
        }
    }

    public static Object parseString(BString json, BMap<BString, Object> options, BTypedesc typed) {
        try {
            return JsonParser.parse(new StringReader(json.getValue()), options, typed);
        } catch (BError e) {
            return e;
        }
    }

    public static Object parseBytes(BArray json, BMap<BString, Object> options, BTypedesc typed) {
        try {
            byte[] bytes = json.getBytes();
            return JsonParser.parse(new InputStreamReader(new ByteArrayInputStream(bytes)), options, typed);
        } catch (BError e) {
            return e;
        }
    }

    public static Object parseStream(Environment env, BStream json, BMap<BString, Object> options, BTypedesc typed) {
        final BObject iteratorObj = json.getIteratorObj();
        BallerinaByteBlockInputStream byteBlockSteam = new BallerinaByteBlockInputStream(env,
                iteratorObj, resolveNextMethod(iteratorObj), resolveCloseMethod(iteratorObj));
        Object result = JsonParser.parse(new InputStreamReader(byteBlockSteam), options, typed);
        if (byteBlockSteam.getError() != null) {
            return byteBlockSteam.getError();
        }
        return result;
    }

    public static BString getNameAnnotation(BMap<BString, Object> value, BString key) {
        if (!(value.getType() instanceof RecordType recordType)) {
            return key;
        }
        BMap<BString, Object> annotations = recordType.getAnnotations();
        for (BString keyV: annotations.getKeys()) {
            String keyStr = keyV.toString();
            if (!keyStr.contains(Constants.FIELD)) {
                continue;
            }
            String fieldName = unescapeIdentifier(keyStr.split(Constants.FIELD_REGEX)[1]);
            if (fieldName.equals(key.getValue())) {
                Map<BString, Object> fieldAnnotation = (Map<BString, Object>) annotations.get(keyV);
                String modifiedName = getModifiedName(fieldAnnotation, fieldName);
                return StringUtils.fromString(modifiedName);
            }
        }
        return key;
    }
}
