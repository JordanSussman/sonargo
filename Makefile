# The `clean` target is intended to clean the Golang workspace and prepare the local changes for submission.
.PHONY: clean
clean: tidy vet fmt fix

# The `fix` target is intended to rewrite the Go source code using old libraries.
.PHONY: fix
fix:
	@echo
	@echo "### Fixing Go Code"
	@go fix ./...

# The `fmt` target is intended to format the Go source code to meet the language standards.
.PHONY: fmt
fmt:
	@echo
	@echo "### Formatting Go Code"
	@go fmt ./...

# The `test` target is intended to run all tests for the Go source code.
.PHONY: test
test:
	@echo
	@echo "### Testing Go Code"
	@go test -covermode=atomic -coverprofile=coverage.out -race ./...

# The `tidy` target is intended to clean up the Go module (a.k.a. dependency) files (go.mod & go.sum).
.PHONY: tidy
tidy:
	@echo
	@echo "### Cleaning Go Dependencies"
	@go mod tidy

# The `vet` target is intended to inspect the Go source code for potential issues.
.PHONY: vet
vet:
	@echo
	@echo "### Vetting Go Code"
	@go vet ./...

###
### The below section contains content from the forked repo that we've left here for posterity.
###

package_name=sonargo
work_dir=sonar
init-clean:
	rm -f ${work_dir}/*.go
	rm -rf integration_testing
	echo "package $(package_name)"> ${work_dir}/doc.go

update: init-clean
	dep ensure -v -update
	go run vendor/github.com/magicsong/generate-go-for-sonarqube/cmd/main/main.go -f assets/api.json -n $(package_name) -o ${work_dir} -e http://192.168.98.8:9000/api -logtostderr=true
	
init: init-clean
	go run $(GOPATH)/src/github.com/magicsong/generate-go-for-sonarqube/cmd/main/main.go -f assets/api.json -n $(package_name) -o ${work_dir} -e http://192.168.98.8:9000/api -logtostderr=true

integration-testing:
	ginkgo --noisyPendings=false -cover --progress --trace ./sonar

no-test-init: 
	rm -f ${work_dir}/*.go
	go run $(GOPATH)/src/github.com/magicsong/generate-go-for-sonarqube/cmd/main/main.go -f assets/api.json -n $(package_name) -o ${work_dir} -e http://192.168.98.8:9000/api -logtostderr=true -no-test