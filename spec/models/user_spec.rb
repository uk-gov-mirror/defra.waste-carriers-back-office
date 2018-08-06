# frozen_string_literal: true

require "cancan/matchers"
require "rails_helper"

RSpec.describe User, type: :model do
  describe "#password" do
    context "when the user's password meets the requirements" do
      let(:user) { build(:user, password: "Secret123") }

      it "should be valid" do
        expect(user).to be_valid
      end
    end

    context "when the user's password is blank" do
      let(:user) { build(:user, password: "") }

      it "should not be valid" do
        expect(user).to_not be_valid
      end
    end

    context "when the user's password has no lowercase letters" do
      let(:user) { build(:user, password: "SECRET123") }

      it "should not be valid" do
        expect(user).to_not be_valid
      end
    end

    context "when the user's password has no uppercase letters" do
      let(:user) { build(:user, password: "secret123") }

      it "should not be valid" do
        expect(user).to_not be_valid
      end
    end

    context "when the user's password has no numbers" do
      let(:user) { build(:user, password: "SuperSecret") }

      it "should not be valid" do
        expect(user).to_not be_valid
      end
    end

    context "when the user's password is too short" do
      let(:user) { build(:user, password: "Sec123") }

      it "should not be valid" do
        expect(user).to_not be_valid
      end
    end
  end

  describe "abilities" do
    subject(:ability) { Ability.new(user) }
    let(:user) { build(:user) }

    context "when the user owns a registration" do
      let(:registration) { build(:registration, account_email: user.email) }

      it "should be able to read it" do
        should be_able_to(:read, registration)
      end

      it "should not able to manage it" do
        should_not be_able_to(:manage, registration)
      end
    end

    context "when the user does not own a registration" do
      let(:registration) { build(:registration, account_email: "foo@test.com") }

      it "should be able to read it" do
        should be_able_to(:read, registration)
      end

      it "should not able to manage it" do
        should_not be_able_to(:manage, registration)
      end
    end

    context "when the user owns a transient_registration" do
      let(:transient_registration) { build(:transient_registration, account_email: user.email) }

      it "should be able to manage it" do
        should be_able_to(:manage, transient_registration)
      end
    end

    context "when the user does not own a transient_registration" do
      let(:transient_registration) { build(:transient_registration, account_email: "foo@test.com") }

      it "should be able to manage it" do
        should be_able_to(:manage, transient_registration)
      end
    end
  end
end
