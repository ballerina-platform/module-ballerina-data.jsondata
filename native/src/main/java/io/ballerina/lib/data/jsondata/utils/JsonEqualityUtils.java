package io.ballerina.lib.data.jsondata.utils;

import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BDecimal;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.math.BigDecimal;

public class JsonEqualityUtils {

    public static boolean deepEquals(Object value1, Object value2) {
        if (value1 == value2) {
            return true;
        }

        if (value1 == null || value2 == null) {
            return false;
        }

        if (value1 instanceof BMap<?, ?> map1 && value2 instanceof BMap<?, ?> map2) {
            return mapsEqual((BMap<BString, Object>) map1, (BMap<BString, Object>) map2);
        }

        if (value1 instanceof BArray array1 && value2 instanceof BArray array2) {
            return arraysEqual(array1, array2);
        }

        if (isNumeric(value1) && isNumeric(value2)) {
            return numbersEqual(value1, value2);
        }

        Class<?> class1 = value1.getClass();
        Class<?> class2 = value2.getClass();

        if (class1 != class2) {
            return false;
        }

        return value1.equals(value2);
    }

    private static boolean mapsEqual(BMap<BString, Object> map1, BMap<BString, Object> map2) {
        if (map1.size() != map2.size()) {
            return false;
        }

        for (BString key : map1.getKeys()) {
            if (!map2.containsKey(key)) {
                return false;
            }

            Object value1 = map1.get(key);
            Object value2 = map2.get(key);

            if (!deepEquals(value1, value2)) {
                return false;
            }
        }

        return true;
    }

    private static boolean arraysEqual(BArray array1, BArray array2) {
        long length1 = array1.getLength();
        long length2 = array2.getLength();

        if (length1 != length2) {
            return false;
        }

        for (int i = 0; i < length1; i++) {
            Object element1 = array1.get(i);
            Object element2 = array2.get(i);

            if (!deepEquals(element1, element2)) {
                return false;
            }
        }

        return true;
    }

    private static boolean isNumeric(Object value) {
        return value instanceof BDecimal || value instanceof Number;
    }

    private static boolean numbersEqual(Object num1, Object num2) {
        BigDecimal bd1 = toBigDecimal(num1);
        BigDecimal bd2 = toBigDecimal(num2);

        if (bd1 == null || bd2 == null) {
            return false;
        }

        return bd1.compareTo(bd2) == 0;
    }

    private static BigDecimal toBigDecimal(Object value) {
        if (value instanceof BDecimal bd) {
            return bd.decimalValue();
        } else if (value instanceof Long l) {
            return BigDecimal.valueOf(l);
        } else if (value instanceof Double d) {
            return BigDecimal.valueOf(d);
        } else if (value instanceof Integer i) {
            return BigDecimal.valueOf(i.longValue());
        } else if (value instanceof Number n) {
            return new BigDecimal(n.toString());
        }
        return null;
    }
}
