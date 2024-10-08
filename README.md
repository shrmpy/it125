# it125
Class project 

![ER](./foodtruck.svg)


Share link to
 [the Lucid Chart diagram](https://lucid.app/lucidchart/dc6640ea-9a83-47e5-9e5f-f7d0418432e4/edit?view_items=p2k1VE-~_3zx&invitationId=inv_cda4ec83-1c2a-4dde-80fe-af748356c846)



### Quickstart
1. Adjust the MySQL env vars in suite_test.go
2. Run go-test

```
go test -v .
```

### Pie chart example
1. Modify the random order item generate parameters in cmd/piechart.go
2. Build cmd/piechart.go
3. export MySQL env vars

```
go build -o test cmd/*.go
export DB_HOST="127.0.0.1"
export DB_PORT="3306"
export DB_USER="root"
export DB_PASS="root"
export DB_DATABASE="it125_foodtruck"
./test
```


### Notes
Modifying sqlc-schema.sql or sqlc-query.sql requires re-generating the files in the data subdir
```
sqlc generate
```

## Credits

Golang [Pie with echarts](https://github.com/go-echarts/examples/tree/master/examples)

Golang [SQL types with sqlc](https://dev.to/eminetto/creating-an-api-using-go-and-sqlc-364o)

Golang [Tests with Testify](https://david-yappeter.medium.com/golang-mysql-integration-test-433a2b00dbfe)

RedHat [OpenShift CLI](https://developers.redhat.com/learning/learn:openshift:foundations-openshift/resource/resources:work-databases-openshift-using-oc-cli-tool)

RedHat [OpenShift commands](https://medium.com/@shura.zakti/openshift-4-command-cheat-sheet-for-system-administrators-32df6e96d8b6)

MySQL (Cloud SQL)
  with [Cloud Run](https://cloud.google.com/sql/docs/mysql/connect-run#terraform)



