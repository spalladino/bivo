class FullTextSearch1288795208 < ActiveRecord::Migration
  def self.up
    execute(<<-'eosql'.strip)
      DROP index IF EXISTS shops_fts_idx
    eosql
    execute(<<-'eosql'.strip)
      CREATE index shops_fts_idx
      ON shops
      USING gin((to_tsvector('english', coalesce("shops"."name", '') || ' ' || coalesce("shops"."description", ''))))
    eosql
  end

  def self.down
    execute(<<-'eosql'.strip)
      DROP index IF EXISTS shops_fts_idx
    eosql
  end
end
