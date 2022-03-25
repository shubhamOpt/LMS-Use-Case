global with sharing class DataTransferObjects {
    global class OperationResult {
        @AuraEnabled
        public boolean isSuccess { get; set; }

        @AuraEnabled
        public List<String> validationErrors { get; set; }

        @AuraEnabled
        public Object data { get; set; }

        public OperationResult() {

        }

        public OperationResult(boolean isSuccess) {
            this.isSuccess = isSuccess;
        }

        public OperationResult(boolean isSuccess, List<String> validationErrors) {
            this.isSuccess = isSuccess;
            this.validationErrors = validationErrors;
        }
    }
}