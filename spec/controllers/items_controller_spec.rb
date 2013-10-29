require 'spec_helper'

describe ItemsController do

  let(:valid_attributes) { FactoryGirl.attributes_for(:item) }

  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all items as @items" do
      Item.delete_all # empty the repo for expected results
      item = Item.create! valid_attributes
      get :index, {}, valid_session
      assigns(:items).should eq([item])
    end
  end

  describe "GET show" do
    it "assigns the requested item as @item" do
      item = Item.create! valid_attributes
      get :show, {id: item.to_param}, valid_session
      assigns(:item).should eq(item)
    end
  end

  describe "GET new" do
    it "assigns a new item as @item" do
      get :new, {}, valid_session
      assigns(:item).should be_a_new(Item)
    end
  end

  describe "GET edit" do
    it "assigns the requested item as @item" do
      item = Item.create! valid_attributes
      get :edit, {id: item.to_param}, valid_session
      assigns(:item).should eq(item)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Item" do
        expect {
          post :create, {item: valid_attributes}, valid_session
        }.to change(Item, :count).by(1)
      end

      it "assigns a newly created item as @item" do
        post :create, {item: valid_attributes}, valid_session
        assigns(:item).should be_a(Item)
        assigns(:item).should be_persisted
      end

      it "redirects to the created item" do
        Item.delete_all # not sure why we need to do this
        post :create, {item: valid_attributes}, valid_session
        response.should redirect_to(Item.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved item as @item" do
        # Trigger the behavior that occurs when invalid params are submitted
        Item.any_instance.stub(:save).and_return(false)
        post :create, {:item => { "type" => "invalid value" }}, valid_session
        assigns(:item).should be_a_new(Item)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Item.any_instance.stub(:save).and_return(false)
        post :create, {:item => { "type" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested item" do
        item = Item.create! valid_attributes
        # Assuming there are no other items in the database, this
        # specifies that the Item created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Item.any_instance.should_receive(:update).with({ "type" => "" })
        put :update, {id: item.to_param, :item => { "type" => "" }}, valid_session
      end

      it "assigns the requested item as @item" do
        item = Item.create! valid_attributes
        put :update, {id: item.to_param, item: valid_attributes}, valid_session
        assigns(:item).should eq(item)
      end

      it "redirects to the item" do
        item = Item.create! valid_attributes
        put :update, {id: item.to_param, item: valid_attributes}, valid_session
        response.should redirect_to(item)
      end
    end

    describe "with invalid params" do
      it "assigns the item as @item" do
        item = Item.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Item.any_instance.stub(:save).and_return(false)
        put :update, {id: item.to_param, :item => { "type" => "invalid value" }}, valid_session
        assigns(:item).should eq(item)
      end

      it "re-renders the 'edit' template" do
        item = Item.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Item.any_instance.stub(:save).and_return(false)
        put :update, {id: item.to_param, :item => { "type" => "invalid value" }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested item" do
      item = Item.create! valid_attributes
      expect {
        delete :destroy, {id: item.to_param}, valid_session
      }.to change(Item, :count).by(-1)
    end

    it "redirects to the items list" do
      item = Item.create! valid_attributes
      delete :destroy, {id: item.to_param}, valid_session
      response.should redirect_to(items_url)
    end
  end

end
