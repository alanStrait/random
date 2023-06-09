defmodule Random.AccountsTest do
  use Random.DataCase

  alias Random.Accounts

  describe "users" do
    alias Random.Accounts.User

    import Random.AccountsFixtures

    @invalid_attrs %{points: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{points: 42}

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.points == 42
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "create_user/1 with out-of-range value returns error changeset" do
      out_of_range_attrs = %{points: -1}
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(out_of_range_attrs)

      out_of_range_attrs = %{points: 101}
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(out_of_range_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{points: 43}

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.points == 43
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
