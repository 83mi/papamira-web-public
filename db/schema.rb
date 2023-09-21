# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_09_12_043013) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgroonga"
  enable_extension "plpgsql"

  create_table "papamira_chats", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "body"
    t.string "host"
    t.string "time"
  end

  create_table "papamira_itemdrops", force: :cascade do |t|
    t.string "data"
  end

  create_table "papamira_items", id: :serial, force: :cascade do |t|
    t.string "index"
    t.string "name"
  end

  create_table "papamira_search_word_days", force: :cascade do |t|
    t.string "server"
    t.string "days"
    t.string "name"
    t.string "count"
  end

  create_table "papamira_search_words", id: :serial, force: :cascade do |t|
    t.string "server"
    t.string "data"
  end

  create_table "papamira_shouts", force: :cascade do |t|
    t.string "stat"
    t.string "server", null: false
    t.string "days", null: false
    t.string "date", null: false
    t.string "name", null: false
    t.string "body"
    t.index ["body"], name: "index_papamira_shouts_on_body", using: :pgroonga
    t.index ["name"], name: "index_papamira_shouts_on_name", using: :pgroonga
  end

  create_table "papamira_user_words", id: :serial, force: :cascade do |t|
    t.string "index"
    t.string "name"
  end

  create_table "papamira_worlds", id: :serial, force: :cascade do |t|
    t.string "server"
    t.string "date"
    t.string "days"
    t.string "tags"
    t.string "body"
  end

  create_table "papamira_yourshop", force: :cascade do |t|
    t.string "data"
    t.string "date"
  end

  create_table "papamira_yourshops", force: :cascade do |t|
    t.string "data"
    t.string "date"
  end

# Could not dump table "pg_aggregate" because of following StandardError
#   Unknown type 'regproc' for column 'aggfnoid'

# Could not dump table "pg_am" because of following StandardError
#   Unknown type 'regproc' for column 'amhandler'

  create_table "pg_amop", id: false, force: :cascade do |t|
    t.oid "oid", null: false
    t.oid "amopfamily", null: false
    t.oid "amoplefttype", null: false
    t.oid "amoprighttype", null: false
    t.integer "amopstrategy", limit: 2, null: false
    t.string "amoppurpose", null: false
    t.oid "amopopr", null: false
    t.oid "amopmethod", null: false
    t.oid "amopsortfamily", null: false
    t.index ["amopfamily", "amoplefttype", "amoprighttype", "amopstrategy"], name: "pg_amop_fam_strat_index", unique: true
    t.index ["amopopr", "amoppurpose", "amopfamily"], name: "pg_amop_opr_fam_index", unique: true
    t.index ["oid"], name: "pg_amop_oid_index", unique: true
  end

# Could not dump table "pg_amproc" because of following StandardError
#   Unknown type 'regproc' for column 'amproc'

# Could not dump table "pg_attrdef" because of following StandardError
#   Unknown type 'pg_node_tree' for column 'adbin'

# Could not dump table "pg_attribute" because of following StandardError
#   Unknown type 'aclitem' for column 'attacl'

  create_table "pg_auth_members", id: false, force: :cascade do |t|
    t.oid "roleid", null: false
    t.oid "member", null: false
    t.oid "grantor", null: false
    t.boolean "admin_option", null: false
    t.index ["member", "roleid"], name: "pg_auth_members_member_role_index", unique: true
    t.index ["roleid", "member"], name: "pg_auth_members_role_member_index", unique: true
  end

  create_table "pg_authid", id: false, force: :cascade do |t|
    t.oid "oid", null: false
    t.string "rolname", null: false
    t.boolean "rolsuper", null: false
    t.boolean "rolinherit", null: false
    t.boolean "rolcreaterole", null: false
    t.boolean "rolcreatedb", null: false
    t.boolean "rolcanlogin", null: false
    t.boolean "rolreplication", null: false
    t.boolean "rolbypassrls", null: false
    t.integer "rolconnlimit", null: false
    t.text "rolpassword", collation: "C"
    t.timestamptz "rolvaliduntil"
    t.index ["oid"], name: "pg_authid_oid_index", unique: true
    t.index ["rolname"], name: "pg_authid_rolname_index", unique: true
  end

  create_table "pg_cast", id: false, force: :cascade do |t|
    t.oid "oid", null: false
    t.oid "castsource", null: false
    t.oid "casttarget", null: false
    t.oid "castfunc", null: false
    t.string "castcontext", null: false
    t.string "castmethod", null: false
    t.index ["castsource", "casttarget"], name: "pg_cast_source_target_index", unique: true
    t.index ["oid"], name: "pg_cast_oid_index", unique: true
  end

# Could not dump table "pg_class" because of following StandardError
#   Unknown type 'xid' for column 'relfrozenxid'

  create_table "pg_collation", id: false, force: :cascade do |t|
    t.oid "oid", null: false
    t.string "collname", null: false
    t.oid "collnamespace", null: false
    t.oid "collowner", null: false
    t.string "collprovider", null: false
    t.boolean "collisdeterministic", null: false
    t.integer "collencoding", null: false
    t.string "collcollate", null: false
    t.string "collctype", null: false
    t.text "collversion", collation: "C"
    t.index ["collname", "collencoding", "collnamespace"], name: "pg_collation_name_enc_nsp_index", unique: true
    t.index ["oid"], name: "pg_collation_oid_index", unique: true
  end

# Could not dump table "pg_constraint" because of following StandardError
#   Unknown type 'pg_node_tree' for column 'conbin'

# Could not dump table "pg_conversion" because of following StandardError
#   Unknown type 'regproc' for column 'conproc'

# Could not dump table "pg_database" because of following StandardError
#   Unknown type 'xid' for column 'datfrozenxid'

  create_table "pg_db_role_setting", id: false, force: :cascade do |t|
    t.oid "setdatabase", null: false
    t.oid "setrole", null: false
    t.text "setconfig", collation: "C", array: true
    t.index ["setdatabase", "setrole"], name: "pg_db_role_setting_databaseid_rol_index", unique: true
  end

# Could not dump table "pg_default_acl" because of following StandardError
#   Unknown type 'aclitem' for column 'defaclacl'

  create_table "pg_depend", id: false, force: :cascade do |t|
    t.oid "classid", null: false
    t.oid "objid", null: false
    t.integer "objsubid", null: false
    t.oid "refclassid", null: false
    t.oid "refobjid", null: false
    t.integer "refobjsubid", null: false
    t.string "deptype", null: false
    t.index ["classid", "objid", "objsubid"], name: "pg_depend_depender_index"
    t.index ["refclassid", "refobjid", "refobjsubid"], name: "pg_depend_reference_index"
  end

  create_table "pg_description", id: false, force: :cascade do |t|
    t.oid "objoid", null: false
    t.oid "classoid", null: false
    t.integer "objsubid", null: false
    t.text "description", null: false, collation: "C"
    t.index ["objoid", "classoid", "objsubid"], name: "pg_description_o_c_o_index", unique: true
  end

  create_table "pg_enum", id: false, force: :cascade do |t|
    t.oid "oid", null: false
    t.oid "enumtypid", null: false
    t.float "enumsortorder", null: false
    t.string "enumlabel", null: false
    t.index ["enumtypid", "enumlabel"], name: "pg_enum_typid_label_index", unique: true
    t.index ["enumtypid", "enumsortorder"], name: "pg_enum_typid_sortorder_index", unique: true
    t.index ["oid"], name: "pg_enum_oid_index", unique: true
  end

  create_table "pg_event_trigger", id: false, force: :cascade do |t|
    t.oid "oid", null: false
    t.string "evtname", null: false
    t.string "evtevent", null: false
    t.oid "evtowner", null: false
    t.oid "evtfoid", null: false
    t.string "evtenabled", null: false
    t.text "evttags", collation: "C", array: true
    t.index ["evtname"], name: "pg_event_trigger_evtname_index", unique: true
    t.index ["oid"], name: "pg_event_trigger_oid_index", unique: true
  end

  create_table "pg_extension", id: false, force: :cascade do |t|
    t.oid "oid", null: false
    t.string "extname", null: false
    t.oid "extowner", null: false
    t.oid "extnamespace", null: false
    t.boolean "extrelocatable", null: false
    t.text "extversion", null: false, collation: "C"
    t.oid "extconfig", array: true
    t.text "extcondition", collation: "C", array: true
    t.index ["extname"], name: "pg_extension_name_index", unique: true
    t.index ["oid"], name: "pg_extension_oid_index", unique: true
  end

# Could not dump table "pg_foreign_data_wrapper" because of following StandardError
#   Unknown type 'aclitem' for column 'fdwacl'

# Could not dump table "pg_foreign_server" because of following StandardError
#   Unknown type 'aclitem' for column 'srvacl'

  create_table "pg_foreign_table", id: false, force: :cascade do |t|
    t.oid "ftrelid", null: false
    t.oid "ftserver", null: false
    t.text "ftoptions", collation: "C", array: true
    t.index ["ftrelid"], name: "pg_foreign_table_relid_index", unique: true
  end

# Could not dump table "pg_index" because of following StandardError
#   Unknown type 'int2vector' for column 'indkey'

  create_table "pg_inherits", id: false, force: :cascade do |t|
    t.oid "inhrelid", null: false
    t.oid "inhparent", null: false
    t.integer "inhseqno", null: false
    t.index ["inhparent"], name: "pg_inherits_parent_index"
    t.index ["inhrelid", "inhseqno"], name: "pg_inherits_relid_seqno_index", unique: true
  end

# Could not dump table "pg_init_privs" because of following StandardError
#   Unknown type 'aclitem' for column 'initprivs'

# Could not dump table "pg_language" because of following StandardError
#   Unknown type 'aclitem' for column 'lanacl'

  create_table "pg_largeobject", id: false, force: :cascade do |t|
    t.oid "loid", null: false
    t.integer "pageno", null: false
    t.binary "data", null: false
    t.index ["loid", "pageno"], name: "pg_largeobject_loid_pn_index", unique: true
  end

# Could not dump table "pg_largeobject_metadata" because of following StandardError
#   Unknown type 'aclitem' for column 'lomacl'

# Could not dump table "pg_namespace" because of following StandardError
#   Unknown type 'aclitem' for column 'nspacl'

  create_table "pg_opclass", id: false, force: :cascade do |t|
    t.oid "oid", null: false
    t.oid "opcmethod", null: false
    t.string "opcname", null: false
    t.oid "opcnamespace", null: false
    t.oid "opcowner", null: false
    t.oid "opcfamily", null: false
    t.oid "opcintype", null: false
    t.boolean "opcdefault", null: false
    t.oid "opckeytype", null: false
    t.index ["oid"], name: "pg_opclass_oid_index", unique: true
    t.index ["opcmethod", "opcname", "opcnamespace"], name: "pg_opclass_am_name_nsp_index", unique: true
  end

# Could not dump table "pg_operator" because of following StandardError
#   Unknown type 'regproc' for column 'oprcode'

  create_table "pg_opfamily", id: false, force: :cascade do |t|
    t.oid "oid", null: false
    t.oid "opfmethod", null: false
    t.string "opfname", null: false
    t.oid "opfnamespace", null: false
    t.oid "opfowner", null: false
    t.index ["oid"], name: "pg_opfamily_oid_index", unique: true
    t.index ["opfmethod", "opfname", "opfnamespace"], name: "pg_opfamily_am_name_nsp_index", unique: true
  end

# Could not dump table "pg_partitioned_table" because of following StandardError
#   Unknown type 'int2vector' for column 'partattrs'

# Could not dump table "pg_pltemplate" because of following StandardError
#   Unknown type 'aclitem' for column 'tmplacl'

# Could not dump table "pg_policy" because of following StandardError
#   Unknown type 'pg_node_tree' for column 'polqual'

# Could not dump table "pg_proc" because of following StandardError
#   Unknown type 'regproc' for column 'prosupport'

  create_table "pg_publication", id: false, force: :cascade do |t|
    t.oid "oid", null: false
    t.string "pubname", null: false
    t.oid "pubowner", null: false
    t.boolean "puballtables", null: false
    t.boolean "pubinsert", null: false
    t.boolean "pubupdate", null: false
    t.boolean "pubdelete", null: false
    t.boolean "pubtruncate", null: false
    t.index ["oid"], name: "pg_publication_oid_index", unique: true
    t.index ["pubname"], name: "pg_publication_pubname_index", unique: true
  end

  create_table "pg_publication_rel", id: false, force: :cascade do |t|
    t.oid "oid", null: false
    t.oid "prpubid", null: false
    t.oid "prrelid", null: false
    t.index ["oid"], name: "pg_publication_rel_oid_index", unique: true
    t.index ["prrelid", "prpubid"], name: "pg_publication_rel_prrelid_prpubid_index", unique: true
  end

# Could not dump table "pg_range" because of following StandardError
#   Unknown type 'regproc' for column 'rngcanonical'

  create_table "pg_replication_origin", id: false, force: :cascade do |t|
    t.oid "roident", null: false
    t.text "roname", null: false, collation: "C"
    t.index ["roident"], name: "pg_replication_origin_roiident_index", unique: true
    t.index ["roname"], name: "pg_replication_origin_roname_index", unique: true
  end

# Could not dump table "pg_rewrite" because of following StandardError
#   Unknown type 'pg_node_tree' for column 'ev_qual'

  create_table "pg_seclabel", id: false, force: :cascade do |t|
    t.oid "objoid", null: false
    t.oid "classoid", null: false
    t.integer "objsubid", null: false
    t.text "provider", null: false, collation: "C"
    t.text "label", null: false, collation: "C"
    t.index ["objoid", "classoid", "objsubid", "provider"], name: "pg_seclabel_object_index", unique: true
  end

  create_table "pg_sequence", id: false, force: :cascade do |t|
    t.oid "seqrelid", null: false
    t.oid "seqtypid", null: false
    t.bigint "seqstart", null: false
    t.bigint "seqincrement", null: false
    t.bigint "seqmax", null: false
    t.bigint "seqmin", null: false
    t.bigint "seqcache", null: false
    t.boolean "seqcycle", null: false
    t.index ["seqrelid"], name: "pg_sequence_seqrelid_index", unique: true
  end

  create_table "pg_shdepend", id: false, force: :cascade do |t|
    t.oid "dbid", null: false
    t.oid "classid", null: false
    t.oid "objid", null: false
    t.integer "objsubid", null: false
    t.oid "refclassid", null: false
    t.oid "refobjid", null: false
    t.string "deptype", null: false
    t.index ["dbid", "classid", "objid", "objsubid"], name: "pg_shdepend_depender_index"
    t.index ["refclassid", "refobjid"], name: "pg_shdepend_reference_index"
  end

  create_table "pg_shdescription", id: false, force: :cascade do |t|
    t.oid "objoid", null: false
    t.oid "classoid", null: false
    t.text "description", null: false, collation: "C"
    t.index ["objoid", "classoid"], name: "pg_shdescription_o_c_index", unique: true
  end

  create_table "pg_shseclabel", id: false, force: :cascade do |t|
    t.oid "objoid", null: false
    t.oid "classoid", null: false
    t.text "provider", null: false, collation: "C"
    t.text "label", null: false, collation: "C"
    t.index ["objoid", "classoid", "provider"], name: "pg_shseclabel_object_index", unique: true
  end

# Could not dump table "pg_statistic" because of following StandardError
#   Unknown type 'anyarray' for column 'stavalues1'

# Could not dump table "pg_statistic_ext" because of following StandardError
#   Unknown type 'int2vector' for column 'stxkeys'

# Could not dump table "pg_statistic_ext_data" because of following StandardError
#   Unknown type 'pg_ndistinct' for column 'stxdndistinct'

  create_table "pg_subscription", id: false, force: :cascade do |t|
    t.oid "oid", null: false
    t.oid "subdbid", null: false
    t.string "subname", null: false
    t.oid "subowner", null: false
    t.boolean "subenabled", null: false
    t.text "subconninfo", null: false, collation: "C"
    t.string "subslotname", null: false
    t.text "subsynccommit", null: false, collation: "C"
    t.text "subpublications", null: false, collation: "C", array: true
    t.index ["oid"], name: "pg_subscription_oid_index", unique: true
    t.index ["subdbid", "subname"], name: "pg_subscription_subname_index", unique: true
  end

# Could not dump table "pg_subscription_rel" because of following StandardError
#   Unknown type 'pg_lsn' for column 'srsublsn'

# Could not dump table "pg_tablespace" because of following StandardError
#   Unknown type 'aclitem' for column 'spcacl'

# Could not dump table "pg_transform" because of following StandardError
#   Unknown type 'regproc' for column 'trffromsql'

# Could not dump table "pg_trigger" because of following StandardError
#   Unknown type 'int2vector' for column 'tgattr'

  create_table "pg_ts_config", id: false, force: :cascade do |t|
    t.oid "oid", null: false
    t.string "cfgname", null: false
    t.oid "cfgnamespace", null: false
    t.oid "cfgowner", null: false
    t.oid "cfgparser", null: false
    t.index ["cfgname", "cfgnamespace"], name: "pg_ts_config_cfgname_index", unique: true
    t.index ["oid"], name: "pg_ts_config_oid_index", unique: true
  end

  create_table "pg_ts_config_map", id: false, force: :cascade do |t|
    t.oid "mapcfg", null: false
    t.integer "maptokentype", null: false
    t.integer "mapseqno", null: false
    t.oid "mapdict", null: false
    t.index ["mapcfg", "maptokentype", "mapseqno"], name: "pg_ts_config_map_index", unique: true
  end

  create_table "pg_ts_dict", id: false, force: :cascade do |t|
    t.oid "oid", null: false
    t.string "dictname", null: false
    t.oid "dictnamespace", null: false
    t.oid "dictowner", null: false
    t.oid "dicttemplate", null: false
    t.text "dictinitoption", collation: "C"
    t.index ["dictname", "dictnamespace"], name: "pg_ts_dict_dictname_index", unique: true
    t.index ["oid"], name: "pg_ts_dict_oid_index", unique: true
  end

# Could not dump table "pg_ts_parser" because of following StandardError
#   Unknown type 'regproc' for column 'prsstart'

# Could not dump table "pg_ts_template" because of following StandardError
#   Unknown type 'regproc' for column 'tmplinit'

# Could not dump table "pg_type" because of following StandardError
#   Unknown type 'regproc' for column 'typinput'

  create_table "pg_user_mapping", id: false, force: :cascade do |t|
    t.oid "oid", null: false
    t.oid "umuser", null: false
    t.oid "umserver", null: false
    t.text "umoptions", collation: "C", array: true
    t.index ["oid"], name: "pg_user_mapping_oid_index", unique: true
    t.index ["umuser", "umserver"], name: "pg_user_mapping_user_server_index", unique: true
  end

end
