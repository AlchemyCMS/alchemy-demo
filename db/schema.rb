# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150318083214) do

  create_table "alchemy_attachments", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "file_name",       limit: 255
    t.string   "file_mime_type",  limit: 255
    t.integer  "file_size",       limit: 4
    t.integer  "creator_id",      limit: 4
    t.integer  "updater_id",      limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.text     "cached_tag_list", limit: 65535
    t.string   "file_uid",        limit: 255
  end

  add_index "alchemy_attachments", ["file_uid"], name: "index_alchemy_attachments_on_file_uid", using: :btree

  create_table "alchemy_cells", force: :cascade do |t|
    t.integer  "page_id",    limit: 4
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "alchemy_contents", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "essence_type", limit: 255
    t.integer  "essence_id",   limit: 4
    t.integer  "element_id",   limit: 4
    t.integer  "position",     limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "creator_id",   limit: 4
    t.integer  "updater_id",   limit: 4
  end

  add_index "alchemy_contents", ["element_id", "position"], name: "index_contents_on_element_id_and_position", using: :btree

  create_table "alchemy_elements", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.integer  "position",        limit: 4
    t.integer  "page_id",         limit: 4
    t.boolean  "public",          limit: 1,     default: true
    t.boolean  "folded",          limit: 1,     default: false
    t.boolean  "unique",          limit: 1,     default: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "creator_id",      limit: 4
    t.integer  "updater_id",      limit: 4
    t.integer  "cell_id",         limit: 4
    t.text     "cached_tag_list", limit: 65535
  end

  add_index "alchemy_elements", ["page_id", "position"], name: "index_elements_on_page_id_and_position", using: :btree

  create_table "alchemy_elements_alchemy_pages", id: false, force: :cascade do |t|
    t.integer "element_id", limit: 4
    t.integer "page_id",    limit: 4
  end

  create_table "alchemy_essence_booleans", force: :cascade do |t|
    t.boolean  "value",      limit: 1
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "creator_id", limit: 4
    t.integer  "updater_id", limit: 4
  end

  add_index "alchemy_essence_booleans", ["value"], name: "index_alchemy_essence_booleans_on_value", using: :btree

  create_table "alchemy_essence_dates", force: :cascade do |t|
    t.datetime "date"
    t.integer  "creator_id", limit: 4
    t.integer  "updater_id", limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "alchemy_essence_files", force: :cascade do |t|
    t.integer  "attachment_id", limit: 4
    t.string   "title",         limit: 255
    t.string   "css_class",     limit: 255
    t.integer  "creator_id",    limit: 4
    t.integer  "updater_id",    limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "alchemy_essence_htmls", force: :cascade do |t|
    t.text     "source",     limit: 65535
    t.integer  "creator_id", limit: 4
    t.integer  "updater_id", limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "alchemy_essence_links", force: :cascade do |t|
    t.string   "link",            limit: 255
    t.string   "link_title",      limit: 255
    t.string   "link_target",     limit: 255
    t.string   "link_class_name", limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "creator_id",      limit: 4
    t.integer  "updater_id",      limit: 4
  end

  create_table "alchemy_essence_pictures", force: :cascade do |t|
    t.integer  "picture_id",      limit: 4
    t.string   "caption",         limit: 255
    t.string   "title",           limit: 255
    t.string   "alt_tag",         limit: 255
    t.string   "link",            limit: 255
    t.string   "link_class_name", limit: 255
    t.string   "link_title",      limit: 255
    t.string   "css_class",       limit: 255
    t.string   "link_target",     limit: 255
    t.integer  "creator_id",      limit: 4
    t.integer  "updater_id",      limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "crop_from",       limit: 255
    t.string   "crop_size",       limit: 255
    t.string   "render_size",     limit: 255
  end

  create_table "alchemy_essence_richtexts", force: :cascade do |t|
    t.text     "body",          limit: 65535
    t.text     "stripped_body", limit: 65535
    t.boolean  "public",        limit: 1
    t.integer  "creator_id",    limit: 4
    t.integer  "updater_id",    limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "alchemy_essence_selects", force: :cascade do |t|
    t.string   "value",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "creator_id", limit: 4
    t.integer  "updater_id", limit: 4
  end

  add_index "alchemy_essence_selects", ["value"], name: "index_alchemy_essence_selects_on_value", using: :btree

  create_table "alchemy_essence_texts", force: :cascade do |t|
    t.text     "body",            limit: 65535
    t.string   "link",            limit: 255
    t.string   "link_title",      limit: 255
    t.string   "link_class_name", limit: 255
    t.boolean  "public",          limit: 1,     default: false
    t.string   "link_target",     limit: 255
    t.integer  "creator_id",      limit: 4
    t.integer  "updater_id",      limit: 4
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  create_table "alchemy_folded_pages", force: :cascade do |t|
    t.integer "page_id", limit: 4
    t.integer "user_id", limit: 4
    t.boolean "folded",  limit: 1, default: false
  end

  create_table "alchemy_languages", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "language_code",  limit: 255
    t.string   "frontpage_name", limit: 255
    t.string   "page_layout",    limit: 255, default: "intro"
    t.boolean  "public",         limit: 1,   default: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "creator_id",     limit: 4
    t.integer  "updater_id",     limit: 4
    t.boolean  "default",        limit: 1,   default: false
    t.string   "country_code",   limit: 255, default: "",      null: false
    t.integer  "site_id",        limit: 4
  end

  add_index "alchemy_languages", ["language_code", "country_code"], name: "index_alchemy_languages_on_language_code_and_country_code", using: :btree
  add_index "alchemy_languages", ["language_code"], name: "index_alchemy_languages_on_language_code", using: :btree
  add_index "alchemy_languages", ["site_id"], name: "index_alchemy_languages_on_site_id", using: :btree

  create_table "alchemy_legacy_page_urls", force: :cascade do |t|
    t.string   "urlname",    limit: 255, null: false
    t.integer  "page_id",    limit: 4,   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "alchemy_legacy_page_urls", ["urlname"], name: "index_alchemy_legacy_page_urls_on_urlname", using: :btree

  create_table "alchemy_pages", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "urlname",          limit: 255
    t.string   "title",            limit: 255
    t.string   "language_code",    limit: 255
    t.boolean  "language_root",    limit: 1
    t.string   "page_layout",      limit: 255
    t.text     "meta_keywords",    limit: 65535
    t.text     "meta_description", limit: 65535
    t.integer  "lft",              limit: 4
    t.integer  "rgt",              limit: 4
    t.integer  "parent_id",        limit: 4
    t.integer  "depth",            limit: 4
    t.boolean  "visible",          limit: 1,     default: false
    t.boolean  "public",           limit: 1,     default: false
    t.boolean  "locked",           limit: 1,     default: false
    t.integer  "locked_by",        limit: 4
    t.boolean  "restricted",       limit: 1,     default: false
    t.boolean  "robot_index",      limit: 1,     default: true
    t.boolean  "robot_follow",     limit: 1,     default: true
    t.boolean  "sitemap",          limit: 1,     default: true
    t.boolean  "layoutpage",       limit: 1,     default: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "creator_id",       limit: 4
    t.integer  "updater_id",       limit: 4
    t.integer  "language_id",      limit: 4
    t.text     "cached_tag_list",  limit: 65535
    t.datetime "published_at"
  end

  add_index "alchemy_pages", ["language_id"], name: "index_pages_on_language_id", using: :btree
  add_index "alchemy_pages", ["parent_id", "lft"], name: "index_pages_on_parent_id_and_lft", using: :btree
  add_index "alchemy_pages", ["urlname"], name: "index_pages_on_urlname", using: :btree

  create_table "alchemy_pictures", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.string   "image_file_name",   limit: 255
    t.integer  "image_file_width",  limit: 4
    t.integer  "image_file_height", limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "creator_id",        limit: 4
    t.integer  "updater_id",        limit: 4
    t.string   "upload_hash",       limit: 255
    t.text     "cached_tag_list",   limit: 65535
    t.string   "image_file_uid",    limit: 255
    t.integer  "image_file_size",   limit: 4
  end

  create_table "alchemy_sites", force: :cascade do |t|
    t.string   "host",                     limit: 255
    t.string   "name",                     limit: 255
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.boolean  "public",                   limit: 1,     default: false
    t.text     "aliases",                  limit: 65535
    t.boolean  "redirect_to_primary_host", limit: 1
  end

  add_index "alchemy_sites", ["host", "public"], name: "alchemy_sites_public_hosts_idx", using: :btree
  add_index "alchemy_sites", ["host"], name: "index_alchemy_sites_on_host", using: :btree

  create_table "alchemy_users", force: :cascade do |t|
    t.string   "firstname",              limit: 255
    t.string   "lastname",               limit: 255
    t.string   "login",                  limit: 255
    t.string   "email",                  limit: 255
    t.string   "gender",                 limit: 255
    t.string   "alchemy_roles",          limit: 255,   default: "member"
    t.string   "language",               limit: 255
    t.string   "encrypted_password",     limit: 128,   default: "",       null: false
    t.string   "password_salt",          limit: 128,   default: "",       null: false
    t.integer  "sign_in_count",          limit: 4,     default: 0,        null: false
    t.integer  "failed_attempts",        limit: 4,     default: 0,        null: false
    t.datetime "last_request_at"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.integer  "creator_id",             limit: 4
    t.integer  "updater_id",             limit: 4
    t.text     "cached_tag_list",        limit: 65535
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
  end

  add_index "alchemy_users", ["alchemy_roles"], name: "index_alchemy_users_on_alchemy_roles", using: :btree
  add_index "alchemy_users", ["email"], name: "index_alchemy_users_on_email", unique: true, using: :btree
  add_index "alchemy_users", ["firstname"], name: "index_alchemy_users_on_firstname", using: :btree
  add_index "alchemy_users", ["lastname"], name: "index_alchemy_users_on_lastname", using: :btree
  add_index "alchemy_users", ["login"], name: "index_alchemy_users_on_login", unique: true, using: :btree
  add_index "alchemy_users", ["reset_password_token"], name: "index_alchemy_users_on_reset_password_token", unique: true, using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "hidden_name",  limit: 255
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.text     "description",  limit: 65535
    t.decimal  "entrance_fee",               precision: 6, scale: 2
    t.boolean  "published",    limit: 1
    t.integer  "location_id",  limit: 4
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 255
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count", limit: 4,   default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

end
