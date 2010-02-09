module RedmineExtraLdap
  module Patches
    module AuthSourceLdapPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
      end

      module ClassMethods
      end

      module InstanceMethods
        # TODO: Refactor the Redmine core so these can be reused
        # instead of copied
        def add_new_users(options={})
          ldap_con = initialize_ldap_con(self.account, self.account_password)
          object_filter = Net::LDAP::Filter.eq( "objectClass", "*" ) 
          dn = String.new
          attrs = []
          ldap_con.search( :base => self.base_dn, 
                           :filter => object_filter,
                           :attributes=> ['dn',
                                          self.attr_login,
                                          self.attr_firstname,
                                          self.attr_lastname,
                                          self.attr_mail]) do |entry|
            attrs = [:firstname => AuthSourceLdap.get_attr(entry, self.attr_firstname),
                     :lastname => AuthSourceLdap.get_attr(entry, self.attr_lastname),
                     :mail => AuthSourceLdap.get_attr(entry, self.attr_mail),
                     :auth_source_id => self.id ]
            new_user = User.create(*attrs) do |user|
              user.login = AuthSourceLdap.get_attr(entry, self.attr_login)
            end

          end
        end

      end
    end
  end
end
