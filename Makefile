WORM_BUCKET_NAME = domz_worm_bucket
WORM_LOG_BUCKET_NAME = domz_worm_log_bucket
RETENTION_TIME = 300s
LOG_RETENTION_TIME = 300s

.PHONY: explain make_bucket make_log_bucket set_up_logs set_bucket_retention \
		set_log_bucket_retention lock_bucket lock_log_bucket
default: explain make_bucket make_log_bucket set_up_logs set_bucket_retention \
		set_log_bucket_retention lock_bucket lock_log_bucket

CHECK_CONTINUE = \
	read -p "Continue? (Y/n) " continue; \
	case "$$continue" in \
		n|N ) echo "Stopping." && exit 1 ;; \
		* ) echo -n ;; \
	esac

MESSAGE = \
	echo ========================================== ;\
	echo $1 ;\
	echo ========================================== ;

# Macro for a comma in arguments. This gets expanded after the arguments are parsed.
, := ,

explain:
	@echo ==========================================
	@echo This Makefile will create a locked WORM bucket in Google Cloud Storage.
	@echo
	@echo First, it will create the WORM bucket. Then it will create a bucket in \
	which to store logs for the WORM bucket.
	@echo Next, it will set up access \& storage logs on the WORM bucket, storing \
	the logs in the log bucket.
	@echo Finally, it will set bucket locks on both.
	@echo
	@echo WORM bucket: $(WORM_BUCKET_NAME)
	@echo WORM log bucket: $(WORM_LOG_BUCKET_NAME)
	@echo Retention period: $(RETENTION_TIME)
	@echo ==========================================
	@$(CHECK_CONTINUE) 

make_bucket:
	@$(call MESSAGE, First$(,) we will make the WORM bucket.)
	@$(CHECK_CONTINUE) 
	gsutil mb gs://$(WORM_BUCKET_NAME)
	@$(call MESSAGE Success!) 

make_log_bucket:
	@$(call MESSAGE, Next$(,) we will make the bucket for logs of changes and access \
	to the WORM bucket.) 
	@$(CHECK_CONTINUE) 
	gsutil mb gs://$(WORM_LOG_BUCKET_NAME)
	@$(call MESSAGE Success!) 

set_up_logs:
	@$(call MESSAGE, Now$(,) we will add permissions for the cloud storage analytics \
	service account to write to the log bucket$(,) and set up the log forwarding.)
	@$(CHECK_CONTINUE) 
	gsutil acl ch -g cloud-storage-analytics@google.com:W gs://$(WORM_LOG_BUCKET_NAME)
	gsutil defacl set project-private gs://$(WORM_LOG_BUCKET_NAME)
	gsutil logging set on -b gs://$(WORM_LOG_BUCKET_NAME) gs://$(WORM_BUCKET_NAME)
	@$(call MESSAGE Success!) 

set_bucket_retention:
	@$(call MESSAGE, Now$(,) we will set a retention period of $(RETENTION_TIME) for the bucket.)
	@$(CHECK_CONTINUE) 
	gsutil retention set $(RETENTION_TIME) gs://$(WORM_BUCKET_NAME)
	@$(call MESSAGE Success!) 

set_log_bucket_retention:
	@$(call MESSAGE, Now$(,) we will set a retention period of $(RETENTION_TIME) for the *logs* bucket.)
	@$(CHECK_CONTINUE) 
	gsutil retention set $(RETENTION_TIME) gs://$(WORM_LOG_BUCKET_NAME)
	@$(call MESSAGE Success!) 

lock_bucket:
	@$(call MESSAGE, Now$(,) we will lock the retention policy on the WORM bucket.\
	NOTE: THIS ACTION IS IRREVERSIBLE. You will not be able to delete this bucket until all objects within it \
	are at least $(RETENTION_TIME) old.)
	@$(CHECK_CONTINUE) 
	gsutil retention lock gs://$(WORM_BUCKET_NAME)
	@$(call MESSAGE Success!) 

lock_log_bucket:
	@$(call MESSAGE, Finally$(,) we will lock the retention policy on the WORM *logs* bucket.\
	NOTE: THIS ACTION IS IRREVERSIBLE. You will not be able to delete this bucket until all objects within it \
	are at least $(RETENTION_TIME) old.)
	@$(CHECK_CONTINUE) 
	gsutil retention lock gs://$(WORM_LOG_BUCKET_NAME)
	@$(call MESSAGE Success!) 

# Optional recipes
test_object:
	@$(call MESSAGE, Going to make a test object in $(WORM_BUCKET_NAME).)
	@$(CHECK_CONTINUE) 
	echo "Test object!" | gsutil cp - gs://$(WORM_BUCKET_NAME)/test_object

delete_test_object:
	@$(call MESSAGE, Going to try to delete the test object in gs://$(WORM_BUCKET_NAME).)
	@$(CHECK_CONTINUE) 
	gsutil rm gs://$(WORM_BUCKET_NAME)/test_object

delete_buckets:
	@$(call MESSAGE, Going to try to delete the WORM and WORM log buckets.)
	@$(CHECK_CONTINUE)
	gsutil rm -r gs://$(WORM_LOG_BUCKET_NAME)
	gsutil rm -r gs://$(WORM_BUCKET_NAME)
	@$(call MESSAGE, Success!)
