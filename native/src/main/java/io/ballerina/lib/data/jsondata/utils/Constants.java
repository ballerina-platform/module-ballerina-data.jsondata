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

import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.types.MapType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BString;

/**
 * Constants for jsondata.
 *
 * @since 0.1.0
 */
public class Constants {
    public static final String FIELD = "$field$.";
    public static final String FIELD_REGEX = "\\$field\\$\\.";
    public static final String NAME = "Name";
    public static final String NULL_VALUE = "null";
    public static final String TRUE = "true";
    public static final String FALSE = "false";

    public static final BString VALUE = StringUtils.fromString("value");
    public static final BString ALLOW_DATA_PROJECTION = StringUtils.fromString("allowDataProjection");
    public static final BString NIL_AS_OPTIONAL_FIELD = StringUtils.fromString("nilAsOptionalField");
    public static final BString ABSENT_AS_NILABLE_TYPE = StringUtils.fromString("absentAsNilableType");
    public static final BString ENABLE_CONSTRAINT_VALIDATION = StringUtils.fromString("enableConstraintValidation");

    public static final MapType JSON_MAP_TYPE = TypeCreator.createMapType(PredefinedTypes.TYPE_JSON);
    public static final MapType ANYDATA_MAP_TYPE = TypeCreator.createMapType(PredefinedTypes.TYPE_ANYDATA);
}
