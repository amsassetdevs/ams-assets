 /**
 * @description Utility class for building soql/sosl search strings
 * @author Angelika Galang
 * @since July 3, 2023
 */

 public inherited sharing class ams_UTL_SearchStringBuilder {

    //constants
    private static final String EMPTY_STRING = '';
    private static final String EMPTY_STRING_1 = ' ';
    private static final String COMMA = ',';

    /**
    * @description builds the base soql string (all records)
    *
    * @param defaultFields fields to query
    * @param objectName object to get records from
    *
    * @return `String` base query string
    */
    public static String soqlSearch(
        List<String> defaultFields,
        String objectName
    ){
        return String.format(
            'SELECT {0} FROM {1}',
            new List<String>{
                String.join(defaultFields,COMMA),
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
    * @return `String` base query string with limit
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
    * @return `String` query string
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
                    EMPTY_STRING_1 + operator + EMPTY_STRING_1
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
    * @return `String` query string
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
            EMPTY_STRING
        );
    }

}