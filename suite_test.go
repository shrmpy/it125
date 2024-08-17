package main

import (
	////"bufio"
	////"context"
	"database/sql"
	"fmt"
	"os"
	"testing"

	_ "github.com/go-sql-driver/mysql"
	"github.com/stretchr/testify/suite"
)

type SuiteTest struct {
	suite.Suite
	db *sql.DB
}

func TestSuite(t *testing.T) {
	os.Setenv("DB_HOST", "127.0.0.1")
	os.Setenv("DB_PORT", "3306")
	os.Setenv("DB_USER", "root")
	os.Setenv("DB_PASS", "root")
	os.Setenv("DB_DATABASE", "it125_foodtruck")
	defer os.Unsetenv("DB_HOST")
	defer os.Unsetenv("DB_PORT")
	defer os.Unsetenv("DB_USER")
	defer os.Unsetenv("DB_PASS")
	defer os.Unsetenv("DB_DATABASE")

	suite.Run(t, new(SuiteTest))
}

// Setup db value
func (t *SuiteTest) SetupSuite() {

	uri := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?parseTime=true",
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASS"),
		os.Getenv("DB_HOST"),
		os.Getenv("DB_PORT"),
		os.Getenv("DB_DATABASE"))
	conn, err := sql.Open("mysql", uri)

	if err != nil {
		////log.Fatalf("Open connection fail: %s", err)
		t.T().Error(err)
	}

	t.db = conn

	// Migration
	/**********************
	ctx := context.Background()
	file, err := os.Open("schema.sql")
	if err != nil {
		////log.Fatalf("Schema fail: %s", err)
		t.T().Error(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		_, err := conn.ExecContext(ctx, scanner.Text())
		if err != nil {
			////log.Fatalf("Migration fail: %s", err)
			t.T().Error(err)
		}
	}

	if err := scanner.Err(); err != nil {
		////log.Fatalf("Scanner fail: %s", err)
		t.T().Error(err)
	}
	*/
}

// Run After All Test Done
func (t *SuiteTest) TearDownSuite() {

	defer t.db.Close()

	// Drop schema
	/***************
	ctx := context.Background()
	_, err := t.db.ExecContext(ctx, "DROP SCHEMA IF EXISTS it125_foodtruck;")
	if err != nil {
		////log.Fatalf("Drop schema fail: %s", err)
		t.T().Error(err)
	}
	*/
}

// Run Before a Test
func (t *SuiteTest) SetupTest() {

}

// Run After a Test
func (t *SuiteTest) TearDownTest() {

}
