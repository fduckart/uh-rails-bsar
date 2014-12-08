class LoadCampuses  < ActiveRecord::Migration 
  def self.up
    uh = [
          ['MAN', 'Manoa'], 
          ['HAW', 'Hawaii'],
          ['HIL', 'Hilo'],
          ['HON', 'Honolulu'],
          ['KAP', 'Kapiolani'],
          ['KAU', 'Kauai'],
          ['LEE', 'Leeward'],
          ['MAU', 'Maui'],
          ['WIN', 'Windward'],
          ['WOA', 'West Oahu']
         ]

    for c in uh
      campus = Campus.new
      campus.code = c[0]
      campus.description = c[1]
      campus.save!
    end
  end
end
