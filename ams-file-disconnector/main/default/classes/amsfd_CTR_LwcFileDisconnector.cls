/**
 * @description Controller Class for LwcFileDisconnector
 * @author Adrian Christopher Habasa
 * @since July 4, 2023
 */
public class amsfd_CTR_LwcFileDisconnector {
    
    /**
     * 
     * @param recordId - Id of the current record
     * @return  `List<ContentDocumentLink>`  - List of Content Document Links Related to Record that is not a note
     */
    @AuraEnabled(cacheable=true)
    public static List<ContentDocumentLink> getContentDocs(String recordId){
        List<ContentDocumentLink> CDLs = amsfd_DAL_ContentDocumentLink.getCDLinksByLinkedEntityId(recordId);
        return CDLs;
    }
 
    @AuraEnabled
    public static String getRecordOwnerId(String recordId)
    {
        Id recId = Id.valueof(recordId);
        String objectName = recId.getSObjectType().getDescribe().getName();
        sObject testObj = amsfd_DAL_ContentDocumentLink.getOwnerId(recordId,objectName);
        System.debug('adrian test ' + testObj.get('OwnerId'));
        //String recordOwnerId= testObj.get('OwnerId');
        return String.valueof(testObj.get('OwnerId'));
    }
    /**
     * 
     * @param contDoc  - List of Content Document Links to be deleted or to be disassociated to the record 
     */
    @AuraEnabled
    public static void deleteContentDocumentLink(List<ContentDocumentLink> contDoc){
        try {
           delete contDoc;
        }catch(Exception ex) {
            System.debug('Initial Test');
        }   
    }
}