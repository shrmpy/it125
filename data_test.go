package main

import (
	"context"
	"database/sql"
	"math"

	"github.com/shrmpy/it125/data"
	"github.com/stretchr/testify/assert"
)

func (t *SuiteTest) TestCreateMenuItem() {
	// Notes: this test demonstrates Go's native database/sql namespace and zero dependency on third party modules
	// Test the stored procedure: insert_menuitem

	ctx := context.Background()
	// prepare sp call
	stmt := "CALL insert_menuitem(?, ?, ?, ?, ?);"
	// confirmation query
	qry := "SELECT id,name,recipe,cost,menu_id FROM menu_item WHERE recipe = ?;"

	// invoke sp with test values
	_, err := t.db.ExecContext(ctx, stmt, sql.Null[int]{Valid: false}, "tiki", "pineapple", "allrecipes.com/88", 7.99)
	assert.NoError(t.T(), err)
	var (
		sequenceNum  uint
		name         string
		recipe       string
		cost         float64
		rootSequence uint
	)
	// retrieve the inserted row back for verification
	row := t.db.QueryRowContext(ctx, qry, "allrecipes.com/88")
	err = row.Scan(&sequenceNum, &name, &recipe, &cost, &rootSequence)
	assert.NoError(t.T(), err)
	assert.Equal(t.T(), "pineapple", name)
	assert.Equal(t.T(), 7.99, cost)
	assert.Greater(t.T(), sequenceNum, uint(10))
	assert.Greater(t.T(), rootSequence, uint(5))
}

func (t *SuiteTest) TestCreateOrderItem() {
	// Notes: this test demonstrates Go's native database/sql namespace and zero dependency on third party modules
	// Test the stored procedure: insert_orderitem

	ctx := context.Background()
	// prepare sp call
	stmt := "CALL insert_orderitem(?, ?, ?, ?, ?, ?, ?);"
	// confirmation query
	qry := "SELECT id,quantity,price,order_id,menuitem_id FROM order_item WHERE quantity = ?;"

	// invoke sp with test values
	_, err := t.db.ExecContext(ctx, stmt, sql.Null[int]{Valid: false}, 3, 5, 3, 12345, 7.99, 5)
	assert.NoError(t.T(), err)
	var (
		sequenceNum      uint
		quantity         uint
		price            float64
		rootSequence     uint
		menuitemSequence uint
	)
	// retrieve the inserted row back for verification
	row := t.db.QueryRowContext(ctx, qry, 12345)
	err = row.Scan(&sequenceNum, &quantity, &price, &rootSequence, &menuitemSequence)
	assert.NoError(t.T(), err)
	assert.Equal(t.T(), 7.99, price)
	assert.Equal(t.T(), uint(5), menuitemSequence)
	assert.Equal(t.T(), rootSequence, uint(6))
}

func (t *SuiteTest) TestCreatePatron() {
	// Notes: this test exercises sqlc generated access layer
	// Test the data table type: patron

	ctx := context.Background()
	q := data.New(t.db)

	// insert new patron data
	args := data.CreatePatronParams{
		Name:      sql.NullString{String: "wolfgang", Valid: true},
		Email:     "wolfgang@amadeus.test",
		NewsOptIn: sql.NullBool{Bool: false, Valid: true},
	}
	result, err := q.CreatePatron(ctx, args)

	assert.NoError(t.T(), err)
	// retrieve inserted row back for verification
	lid, err := result.LastInsertId()
	var seq int32
	// generated method accepts int32
	if lid < math.MaxInt32 {
		seq = int32(lid)
	} else {
		t.T().Error("patrons.id int64 size")
	}
	// find by ID call
	patron, err := q.Patron(ctx, seq)

	assert.NoError(t.T(), err)
	assert.Equal(t.T(), sql.NullString{String: "wolfgang", Valid: true}, patron.Name)
	assert.Equal(t.T(), "wolfgang@amadeus.test", patron.Email)
	assert.Equal(t.T(), sql.NullBool{Bool: false, Valid: true}, patron.NewsOptIn)
}

func (t *SuiteTest) TestListMenus() {
	ctx := context.Background()
	q := data.New(t.db)

	// retrieve menus records
	list, err := q.ListMenus(ctx)

	assert.NoError(t.T(), err)
	assert.Equal(t.T(), len(list), 11)
}

func (t *SuiteTest) TestListCashiers() {
	ctx := context.Background()
	q := data.New(t.db)

	// retrieve cashier counts
	list, err := q.ListCashiers(ctx)

	assert.NoError(t.T(), err)
	assert.Equal(t.T(), len(list), 5)
}
