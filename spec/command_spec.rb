require 'spec_helper'

describe Command do

  before do
    @cmd = Command.new(StoreAccessor.new)
  end

  it 'can set a value and get it back' do
    @cmd.set(:val, 123)
    @cmd.get(:val).should == 123
  end

  it 'returns count of values' do
    @cmd.set(:val, 123)
    @cmd.set(:val2, 123)
    @cmd.numequalto(123).should == 2
  end

  it 'returns count of values as 0 if not found' do
    @cmd.numequalto(123).should == 0
  end

  it 'unsetting a value reduces count' do
    @cmd.set(:val, 123)
    @cmd.numequalto(123).should == 1
    @cmd.unset(:val)
    @cmd.numequalto(123).should == 0
  end

  context 'with a transaction' do

    context 'get:' do

      it 'gets the new value back' do
        @cmd.set(:val, 123)
        @cmd.begin_tx
        @cmd.set(:val, 234)
        @cmd.get(:val).should == 234
      end

      it 'can roll back to old value' do
        @cmd.set(:val, 123)
        @cmd.begin_tx
        @cmd.set(:val, 234)
        @cmd.get(:val).should == 234
        @cmd.rollback
        @cmd.get(:val).should == 123
      end

      it 'can commit transaction' do
        @cmd.set(:val, 123)
        @cmd.begin_tx
        @cmd.set(:val, 234)
        @cmd.commit
        @cmd.get(:val).should == 234
      end

      it 'commit returns an error when no transaction in progress' do
        @cmd.commit.should == 'NO TRANSACTION'
      end

      it 'rollback returns an error when no transaction in progress' do
        @cmd.rollback.should == 'NO TRANSACTION'
      end

      it 'unsetting a value in an open transaction will override a set value in underlying DB' do
        @cmd.set(:val, 123)
        @cmd.begin_tx
        @cmd.unset(:val)
        @cmd.store_accessor.instance_variable_get('@root_store')[:val].should == 123
        @cmd.get(:val).should be_nil
      end

      it 'unsetting a value in a committed transaction will override a set value in underlying DB' do
        @cmd.set(:val, 123)
        @cmd.begin_tx
        @cmd.unset(:val)
        @cmd.commit
        @cmd.store_accessor.instance_variable_get('@root_store')[:val].should be_nil
        @cmd.get(:val).should be_nil
      end

    end

    context 'numequalto:' do

      it 'includes count from open transactions' do
        @cmd.set(:val, 123)
        @cmd.begin_tx
        @cmd.set(:val2, 123)
        @cmd.numequalto(123).should == 2
      end

      it 'retains count after committing transaction' do
        @cmd.set(:val, 123)
        @cmd.begin_tx
        @cmd.set(:val2, 123)
        @cmd.commit
        @cmd.numequalto(123).should == 2
      end

      it 'returns correct count when unsetting in a transaction' do
        @cmd.set(:val, 123)
        @cmd.begin_tx
        @cmd.unset(:val)
        @cmd.numequalto(123).should == 0
        @cmd.commit
        @cmd.numequalto(123).should == 0
      end

    end
  end

  context 'Example 1' do
    it 'produces specified output' do
      @cmd.set :a, 10
      @cmd.set :b, 10
      @cmd.numequalto(10).should == 2
      @cmd.numequalto(20).should == 0
      @cmd.unset :a
      @cmd.numequalto(10).should == 1
      @cmd.set :b, 30
      @cmd.numequalto(10).should == 0
    end
  end

  context 'Example 2' do
    it 'produces specified output' do
      @cmd.begin_tx
      @cmd.set :a, 10
      @cmd.get(:a).should == 10
      @cmd.begin_tx
      @cmd.set :a, 20
      @cmd.get(:a).should == 20
      @cmd.rollback
      @cmd.get(:a).should == 10
      @cmd.rollback
      @cmd.get(:a).should be_nil
    end
  end

  context 'Example 3' do
    it 'produces specified output' do
      @cmd.begin_tx
      @cmd.set :a, 30
      @cmd.begin_tx
      @cmd.set :a, 40
      @cmd.commit
      @cmd.get(:a).should == 40
      @cmd.rollback.should == 'NO TRANSACTION'
    end
  end

  context 'Example 4' do
    it 'produces specified output' do
      @cmd.set :a, 50
      @cmd.begin_tx
      @cmd.get(:a).should == 50
      @cmd.set :a, 60
      @cmd.begin_tx
      @cmd.unset :a
      @cmd.get(:a).should be_nil
      @cmd.rollback
      @cmd.get(:a).should == 60
      @cmd.commit
      @cmd.get(:a).should == 60
    end
  end

  context 'Example 5' do
    it 'produces specified output' do
      @cmd.set :a, 10
      @cmd.begin_tx
      @cmd.numequalto(10).should == 1
      @cmd.begin_tx
      @cmd.unset :a
      @cmd.numequalto(10).should == 0
      @cmd.rollback
      @cmd.numequalto(10).should == 1
    end
  end
end