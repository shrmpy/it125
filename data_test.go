package main

import (
	"context"
	"database/sql"

	"github.com/shrmpy/it125/data"
	"github.com/stretchr/testify/assert"
)

func (t *SuiteTest) TestCreatePatron() {
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
	_, err = result.LastInsertId()

	// todo need the find by ID call

	assert.NoError(t.T(), err)
	////assert.Greater(t.T(), id, 5)
}

func (t *SuiteTest) TestListMenus() {
	ctx := context.Background()
	q := data.New(t.db)

	// retrieve menus records
	list, err := q.ListMenus(ctx)

	assert.NoError(t.T(), err)
	assert.Equal(t.T(), len(list), 10)
}

func (t *SuiteTest) TestListCashiers() {
	ctx := context.Background()
	q := data.New(t.db)

	// retrieve cashier counts
	list, err := q.ListCashiers(ctx)

	assert.NoError(t.T(), err)
	assert.Equal(t.T(), len(list), 5)
}
