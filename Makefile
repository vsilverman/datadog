TERRAFORM=./scripts/terraform
PLAN=terraform-plan.out

apply:
	$(TERRAFORM) apply -auto-approve=true $(PLAN)

build.docker:
	$(MAKE) -C docker build

test.docker:
	cd docker && $(MAKE) check

publish.docker:
	$(MAKE) -C docker publish

clean:
	rm -f ${PLAN}
	rm -Rf .terraform/

destroy:
	$(TERRAFORM) destroy -auto-approve=true plans


# Read init variable from credentials
init: clean
	if [ -f 'credentials' ]; then\
		. './credentials' ;\
	fi; \
	$(TERRAFORM) init \
		-backend-config="storage_account_name=$$TF_BACKEND_STORAGE_ACCOUNT_NAME" \
		-backend-config="container_name=$$TF_BACKEND_CONTAINER_NAME" \
		-backend-config="key=$$TF_BACKEND_CONTAINER_FILE" \
		-backend-config="access_key=$$TF_BACKEND_STORAGE_ACCOUNT_KEY" \
		-force-copy \
		plans

init-local: clean
	if [ -f './plans/backend.tf' ]; then\
		rm ./plans/backend.tf ;\
	fi; \
	$(TERRAFORM) init plans

plan: refresh
	$(TERRAFORM) plan -out=$(PLAN) plans

refresh:
	$(TERRAFORM) refresh plans

validate:
	$(TERRAFORM) validate plans


.PHONY: apply clean destroy init init-local plan refresh validate
