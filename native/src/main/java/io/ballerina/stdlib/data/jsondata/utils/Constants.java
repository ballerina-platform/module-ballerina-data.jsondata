package io.ballerina.stdlib.data.jsondata.utils;

import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.MapType;

public class Constants {
    public static final MapType JSON_MAP_TYPE = TypeCreator.createMapType(PredefinedTypes.TYPE_JSON);
    public static final MapType ANYDATA_MAP_TYPE = TypeCreator.createMapType(PredefinedTypes.TYPE_ANYDATA);
}
