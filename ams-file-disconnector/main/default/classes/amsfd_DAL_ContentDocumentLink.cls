/**
 * @description Data service for Content Document Link object
 * @author Adrian Christopher Habasa
 * @since July 4, 2023
 */
public inherited sharing class amsfd_DAL_ContentDocumentLink {

    //constants
    public static final String OBJECT_NAME = ContentDocumentLink.SObjectType.getDescribe().getLocalName();
    public static final String CD_OBJECT_NAME = ContentDocument.SObjectType.getDescribe().getLocalName();
    private static final String OP_AND = 'AND';  
    private static final String SNOTE = 'SNOTE';
    
     /**
     * @description
     *
     * @return  `List<String>` - List of field names to be queried 
     */
    private static List<String> getDefaultFields(){
        return new List<String>{
            ContentDocumentLink.Id.getDescribe().getLocalName(),
            ContentDocumentLink.LinkedEntityId.getDescribe().getLocalName(),
            CD_OBJECT_NAME + '.' + ContentDocument.Title.getDescribe().getLocalName(),
            CD_OBJECT_NAME + '.' + ContentDocument.FileType.getDescribe().getLocalName(),
            CD_OBJECT_NAME + '.' + ContentDocument.OwnerId.getDescribe().getLocalName(),
            CD_OBJECT_NAME + '.' + ContentDocument.ContentSize.getDescribe().getLocalName(),
            CD_OBJECT_NAME + '.' + ContentDocument.CreatedDate.getDescribe().getLocalName()
        };
    }
    
     /**
     * @description 
     *
     * @param recordId - Id of the current record
     *
     * @return  `List<ContentDocumentLink>` - List of Content Document Links Related to Record that is not a note
     */

    public static List<ContentDocumentLink> getCDLinksByLinkedEntityId(String recordId){
        return Database.query(
            ams_UTL_SearchStringBuilder.soqlSearch(
                getDefaultFields(),
                OBJECT_NAME,
                new List<String>{
                    'LinkedEntityId =: recordId',
                    'ContentDocument.FileType !=: SNOTE'
                },
                OP_AND
            )
        );
    }

    public static sObject getOwnerId (String recordId, String objectName)
    {
        return Database.query(
            ams_UTL_SearchStringBuilder.soqlSearch(
               new List<String>{'Id','OwnerId'},
               objectName,
                'Id =: recordId'
            )
        );
    }
}