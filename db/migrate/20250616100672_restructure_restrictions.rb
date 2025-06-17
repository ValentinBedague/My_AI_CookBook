class RestructureRestrictions < ActiveRecord::Migration[7.1]
  def change
    # Supprimer l'ancienne table restrictions
    drop_table :restrictions

    # Créer la nouvelle table restrictions
    create_table :restrictions do |t|
      t.string :name, null: false
      t.timestamps
      t.index :name, unique: true
    end

    # Créer la table de jointure
    create_table :user_restrictions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :restriction, null: false, foreign_key: true
      t.timestamps
      t.index [:user_id, :restriction_id], unique: true
    end
  end
end
