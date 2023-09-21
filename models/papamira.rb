ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
class PapamiraChat < ActiveRecord::Base; end
class PapamiraItem < ActiveRecord::Base; end
class PapamiraUserWord < ActiveRecord::Base; end
class PapamiraWorld < ActiveRecord::Base; end
class PapamiraSearchWord < ActiveRecord::Base; end
class PapamiraYourshop < ActiveRecord::Base; end
class PapamiraItemdrop < ActiveRecord::Base; end

class PapamiraShout < ActiveRecord::Base
  scope :full_text_search, -> (query) {
    where("body @@ ?", query)
  }
  scope :full_text_or_search, -> (query) {
    where("body &@~ ?", query)
  }
end

class PapamiraSearchWordDays < ActiveRecord::Base; end
