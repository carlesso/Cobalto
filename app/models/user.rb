# encoding: utf-8
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :phone, :shared_pwd, :name, :surname, :privacy, :shared_pwd_confirmation, :code_check, :code, :username
  attr_accessor :privacy, :shared_pwd_confirmation, :code_check

  has_many :sms

  before_validation :fix_number_format_and_pwd
  after_create :generate_request

  validates :name, :length => {:minimum => 3}
  validates :surname, :length => {:minimum => 3}
  validates :shared_pwd, :length => {:minimum => 6}
  validates :phone, :uniqueness => true
  validates :privacy, :acceptance => true, :on => :create

  validate :match_of_pwd
  validate :phone_format

  def fullname
    "#{name} #{surname}"
  end

  def fix_number_format_and_pwd
    self.phone = "" if phone.nil?
    self.phone.gsub! /[^0-9\+]/, ""
    self.phone = "+39#{self.phone}" unless phone[0..2] == "+39"
    puts "importo pass e pass_conf a #{self.shared_pwd}"
    puts "E invece #{self.shared_pwd_confirmation}"
    self.password = self.shared_pwd
    self.password_confirmation = self.shared_pwd
  end

  def match_of_pwd
    if shared_pwd_confirmation != shared_pwd
      errors.add :shared_pwd_confirmation, "La password non corrisponde!"
    end
  end

  def phone_format
    unless phone.match /^\+393[0-9]{9}$/
      errors.add :phone, "Il formato del numero non é valido!"
    end
  end

  def resend_code
    self.update_attribute :code, (10000 + rand(90000)).to_s
    s = self.sms.create :phone => self.phone,
      :content => "Il tuo codice di attivazione é #{self.code}. Grazie per aver utilizzati il servizio SeiConnesso.org"
    s.delivery!
  end

  def generate_request
    tmp_username = "#{name.downcase.gsub(/[^a-z]/, "")}.#{surname.downcase.gsub(/[^a-z]/, "")}"
    unless User.find_by_username(tmp_username).nil?
      prog = 1
      while !User.find_by_username("#{tmp_username}#{prog.to_s}").nil?
        prog += 1
      end
      tmp_username = "#{tmp_username}#{prog.to_s}"
    end

    puts "username to #{tmp_username}"

    self.update_attribute :code, (10000 + rand(90000)).to_s
    self.update_attribute :username, tmp_username
    s = self.sms.create :phone => self.phone,
      :content => "Il tuo codice di attivazione é #{self.code}. Grazie per aver utilizzati il servizio SeiConnesso.org"
    s.delivery!
  end

  def do_activate
    ssh_command = "useradd.sh password '#{username}' '#{shared_pwd}' '#{phone}' 'Descrizione'"
    logger.info "Executing ssh -i /home/carlesso/.ssh/cg.seiconnesso.org_rsa admin@192.168.254.1 \"#{ssh_command}\""
    # `ssh -i /home/carlesso/.ssh/cg.seiconnesso.org_rsa admin@192.168.254.1 "#{ssh_command}"` 
  end

  def do_delete_user
    user.destroy unless user.nil?
    ssh_command = "userdel.sh password '#{username}' '#{password}' "
    logger.info "Removing user #{username} from ZeroShell"
    logger.info "Executing ssh -i /home/carlesso/.ssh/cg.seiconnesso.org_rsa admin@192.168.254.1 \"#{ssh_command}\""
    # `ssh -i /home/carlesso/.ssh/cg.seiconnesso.org_rsa admin@192.168.254.1 "#{ssh_command}"` 
  end
end
