# ActiverecordJsonLoader

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/activerecord_json_loader`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord_json_loader'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord_json_loader

## Usage

### Basic
please include sentence on ActiveRecord's Model
```
  include ActiverecordJsonLoader

```

When you defined model like this
```
class Item < ActiveRecord::Base
  include ActiverecordJsonLoader
end 

schema
///////////
  create_table "Items", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end
///////////
```

and exsit file json file like context,
```
[
  { "id": 1, "name": "hoge" },
  { "id": 2, "name": "huga" }
]
```

you'll be able to import the following description(json file path is /foo/bar/items.json).
```
Item.import_from_json "/foo/bar/items.json"
```

If json single object following description, it can be used in the same way.
```
{ "id": 1, "name": "hoge" }
```

### Association support
If you've used association model
example
```

class Item < ActiveRecord::Base
  include ActiverecordJsonLoader
  has_many :item_effects
end 

class ItemEffect < ActiveRecord::Base
  include ActiverecordJsonLoader
end 

schema
///////////
  create_table "Items", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "Item_effects", force: :cascade do |t|
    t.integer "value", null: false
    t.integer "item_id", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end
///////////
```
you can import such json structure
```
[
  {
    "id": 1,
    "name": "hoge",
    "item_effects":[
      { "value": 1 },
      { "value": 2 },
      { "value": 3 }
    ]
  },
  {
    "id": 2,
    "name": "huga",
    "item_effects":[
      { "value": 1 },
      { "value": 2 },
      { "value": 3 }
    ]
  },
  {
    "id": 3,
    "name": "piyo",
    "item_effects":[
      { "value": 1 },
      { "value": 2 },
      { "value": 3 }
    ]
  }
]
```
You can also import in the same way if it multistage association in the correct json description.

### Versioning number
If importing target schema has version column, It will be increment automatically each time a record is updated.
But, if same data importing (no change), version is not updated.
Also, having assosiation and updating child association, parent version is updated

## Note that

* If id does not exist json's attributes, new record will be created. As long as it does not want this thing , always please do put the id.
* Case of has_many association existed, always sync import data. Example for previous model structure (item and item_effect), if the effect associated with the item Two importing the data associated with three one state , and is adjusted to two.
* belong_to assosiasion is not supported
```
when before imported data is
  {
    "id": 1,
    "name": "hoge",
    "item_effects":[
      { "value": 1 },
      { "value": 2 },
      { "value": 3 }
    ]
  }
and after is...
  {
    "id": 1,
    "name": "hoge",
    "item_effects":[
      { "value": 1 },
      { "value": 2 }
    ]
  }

the result is that..
Item.find(1).item_effects
>> [#<ItemEffect id: 1, item_id: 1, value: 1, created_at: "2015-09-15 09:32:19", updated_at: "2015-09-15 09:32:19">, #<ItemEffect id: 2, item_id: 1, value: 2, created_at: "2015-09-15 09:32:19", updated_at: "2015-09-15 09:32:19">] 
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/activerecord_json_loader/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
