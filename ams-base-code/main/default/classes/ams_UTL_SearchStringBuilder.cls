 /**
 * @description Utility class for building soql/sosl search strings
 * @author Angelika Galang
 * @since July 3, 2023
 */

 public inherited sharing class ams_UTL_SearchStringBuilder {

    /**
    * @description builds the base soql string (all records)
    *
    * @param defaultFields fields to query
    * @param objectName object to get records from
    *
    * @return base query string
    */
    public static String soqlSearch(
        List<String> defaultFields,
        String objectName
    ){
        return String.format(
            'SELECT {0} FROM {1}',
            new List<String>{
                String.join(defaultFields,ams_UTL_Constants.COMMA),
                objectName
            }
        );
    }

    /**
    * @description builds the base soql string (with limit)
    *
    * @param defaultFields fields to query
    * @param objectName object to get records from
    * @param limitValue number of records
    *
    * @return base query string with limit
    */
    public static String soqlSearch(
        List<String> defaultFields,
        String objectName,
        Integer limitValue
    ){
        return String.format(
            '{0} LIMIT {1}',
            new List<String>{
                soqlSearch(defaultFields,objectName),
                String.valueOf(limitValue)
            }
        );
    }

    /**
    * @description builds the soql query in string format with multiple conditions (singular operator)
    *
    * @param defaultFields fields to query
    * @param objectName object to get records from
    * @param conditions list of conditions
    * @param operator operator to use in conditions
    *
    * @return query string
    */
    public static String soqlSearch(
        List<String> defaultFields,
        String objectName,
        List<String> conditions,
        String operator
    ){
        return String.format(
            '{0} WHERE {1}',
            new List<String>{
                soqlSearch(defaultFields,objectName),
                String.join(
                    conditions,
                    ams_UTL_Constants.EMPTY_STRING_1 + operator + ams_UTL_Constants.EMPTY_STRING_1
                )
            }
        );
    }

    /**
    * @description builds the soql query in string format with single condition
    *
    * @param defaultFields fields to query
    * @param objectName object to get records from
    * @param condition singular condition
    *
    * @return query string
    */
    public static String soqlSearch(
        List<String> defaultFields,
        String objectName,
        String condition
    ){
        return soqlSearch(
            defaultFields,
            objectName,
            new List<String>{ condition },
            ams_UTL_Constants.EMPTY_STRING
        );
    }

}