package io.ballerina.lib.data.jsondata.utils;

import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BTypedesc;
import io.ballerina.stdlib.constraint.Constraints;

import static io.ballerina.lib.data.jsondata.utils.Constants.EMPTY;
import static io.ballerina.lib.data.jsondata.utils.Constants.ESCAPE_SLASH;

public class DataUtils {
    public static Object validateConstraints(Object convertedValue, BTypedesc typed, boolean requireValidation) {
        if (!requireValidation) {
            return convertedValue;
        }

        Object result = Constraints.validate(convertedValue, typed);
        if (result instanceof BError bError) {
            return DiagnosticLog.createJsonError(getPrintableErrorMsg(bError));
        }
        return convertedValue;
    }

    private static String getPrintableErrorMsg(BError err) {
        String errorMsg = err.getMessage() != null ? err.getMessage() : "";
        Object details = err.getDetails();
        if (details != null && !details.toString().equals("{}")) {
            errorMsg += ", " + details;
        }
        return errorMsg;
    }

    public static String unescapeIdentifier(String parameterName) {
        return parameterName.replaceAll(ESCAPE_SLASH, EMPTY);
    }
}
