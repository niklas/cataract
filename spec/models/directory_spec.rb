require File.dirname(__FILE__) + '/../spec_helper'

describe Directory do
  let(:path) { "nyan/NYan/nyAN" }
  let(:pathname) { Pathname.new(path) }

  context "relative_path" do
    it "should accept path as string and convert it to Pathname" do
      directory = create :directory, :relative_path => path
      directory.reload
      directory.relative_path.should be_a(Pathname)
      directory.relative_path.should == pathname
    end

    it "serializes Pathname" do
      directory = create :directory, :relative_path => pathname
      directory.relative_path.should be_a(Pathname)
      directory.relative_path.should == pathname
    end

    it "is findable by pathname" do
      directory = create :directory, :relative_path => pathname
      Directory.by_relative_path(pathname).first.should == directory
    end

    it "must be relative" do
      directory = build :directory
      directory.relative_path = '/tmp/lol'
      directory.should_not be_valid
    end

    it "uses disk to create absolute path" do
      directory = create :directory, :relative_path => path
      directory.reload
      directory.path.should be_a(Pathname)
      directory.path.should == directory.disk.path+pathname
    end

    it "cannot already exist in db on same disk" do
      disk = create :disk
      create :directory, relative_path: path, disk: disk
      dir = build(:directory, relative_path: path, disk: disk)
      dir.should_not be_valid
    end

    it "should be used for name if none present" do
      dir = build(:directory, relative_path: 'just/the/last/matters to me', name: nil)
      dir.name.should == 'matters to me'
    end

    it "should be found prefixing" do
      directory = create :directory, :relative_path => pathname
      found  = Directory.of directory.path/'some.file'
      found.should == directory
    end
  end

  context 'creating' do
    let(:creating) { lambda { directory.tap(&:save!) } }
    let(:directory) { build(:blank_directory, attr) }
    let(:disk) { create :disk, path: '/media/disk' }
    before :each do
      Disk.stub(:find_or_create_by_path).and_return(disk)
    end

    context 'by full_path' do
      let(:full_path) { '/media/disk/sub1/sub2/thename' }
      let(:attr) {{ full_path: full_path }}
      it "finds or creates disk" do
        Disk.should_receive(:find_or_create_by_path).
          with(Pathname.new(full_path)).
          and_return(disk)
        creating.call
      end
      it "sets relative path" do
        directory.should_receive(:relative_path=).with(Pathname.new('sub1/sub2/thename'))
        creating.call
      end
      it "sets full_path" do
        creating.call
        directory.full_path.to_s.should == '/media/disk/sub1/sub2/thename'
      end
      it "sets name" do
        creating.call
        directory.name.should == 'thename'
      end
    end

    context 'by disk and relative path' do
      let(:attr) {{ disk: disk, relative_path: 'sub1/sub2/a name' }}
      it "finds or creates parent directories" do
        creating.should change(Directory, :count).from(0).to(3)
        Directory.order('name').all.map(&:name).should == ['a name', 'sub1', 'sub2']
      end
      it "sets name" do
        creating.call
        directory.name.should == 'a name'
      end
      it "sets full_path" do
        creating.call
        directory.full_path.to_s.should == '/media/disk/sub1/sub2/a name'
      end
    end

    context 'by disk and name' do
      let(:attr) {{ disk: disk, name: 'thename' }}
      before(:each) { creating.call }
      it "assigns no parent" do
        directory.parent.should be_nil
      end
      it "keeps name" do
        directory.name.should == 'thename'
      end
      it "sets full_path" do
        creating.call
        directory.full_path.to_s.should == '/media/disk/thename'
      end
    end

    let(:parent) { create :directory, disk: disk, name: 'parent' }
    context 'by parent and name' do
      let(:attr)  {{ parent: parent, name: 'thename' }}
      it "assigns disk from parent" do
        creating.call
        directory.disk.should == disk
      end
      it "keeps name" do
        creating.call
        directory.name.should == 'thename'
      end
      it "sets full_path" do
        creating.call
        directory.full_path.to_s.should == '/media/disk/parent/thename'
      end
    end

    context 'by parent and relative path' do
      let!(:sub1) { create :directory, name: 'sub1', parent: parent }
      let(:attr)  {{ parent: parent, relative_path: 'sub1/sub2/thename' }}
      it "assigns disk from parent" do
        creating.call
        directory.disk.should == disk
      end
      it "creates or finds intermediate directories" do
        creating.should change(Directory, :count).from(2).to(4)
      end
      it "sets parent to the deepest intermediate directory" do
        creating.call
        directory.parent.name.should == 'sub2'
      end
      it "sets name" do
        creating.call
        directory.name.should == 'thename'
      end
      it "sets full_path" do
        creating.call
        directory.full_path.to_s.should == '/media/disk/sub1/sub2/thename'
      end
    end
  end

  context "assigning name on creation" do
    it "should create path from the disk's path an the name" do
      disk = create :disk, path: "/media/Zeug"
      directory = build :directory, disk: disk, name: "krams", relative_path: nil
      directory.path.to_s.should == "/media/Zeug/krams"
    end
  end

  context "copies" do
    it "should be found through relative path" do
      series1 = create :directory, relative_path: 'Serien'
      series2 = create :directory, relative_path: 'Serien'

      series1.copies.should include(series2)
      series2.copies.should include(series1)

      series1.copies.should_not include(series1)
      series2.copies.should_not include(series2)
    end
  end
end

describe Directory, 'filter' do
  let(:directory) { build :directory, filter: "insensitive" }
  it "ignores case" do
    "inSenSitiVe".should match(directory.regexp)
  end
end
