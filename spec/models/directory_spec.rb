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
    let(:creating) { lambda { directory.tap(&:create!) } }
    let(:directory) { build(:blank_directory, attr) }
    let(:disk) { create :disk, '/media/disk' }

    context 'by path' do
      let(:attr) {{ path: '/media/disk/sub1/sub2/thename' }}
      it "finds or creates disk"
      it "sets relative path"
    end

    context 'by disk and relative path' do
      let(:attr) {{ disk: disk, relative_path: 'sub1/sub2/thename' }}
      it "finds or creates disk"
      it "finds or creates parent directories"
      it "sets name"
    end

    context 'by disk and name' do
      let(:attr) {{ disk: disk, name: 'thename' }}
      it "finds or creates disk"
      it "assigns no parent"
      it "keeps name"
    end

    let(:parent) { create :directory, disk: disk, name: 'parent' }
    context 'by parent and name' do
      let(:attr)  {{ parent: parent, name: 'thename' }}
      it "assigns disk from parent"
      it "keeps name"
    end

    context 'by parent and relative path' do
      let(:sub1) { create :directory, name: 'sub1', disk: disk }
      let(:attr)  {{ parent: parent, relative_path: 'sub1/sub2/thename' }}
      it "assigns disk from parent"
      it "creates or finds intermediate directories"
      it "sets name"
    end
  end

  context "disk" do
    it "should be auto-set by parent" do
      parent = create :directory
      new = Directory.new parent: parent
      new.valid?
      new.disk.should == parent.disk
    end
  end

  context "autocreation" do
    include FakeFS::SpecHelpers
    it "should create on filesystem if asked for" do
      directory = create :directory, :relative_path => path, virtual: "false"
      File.directory?(directory.path).should be_true
    end
    it "should create on filesystem only if asked for" do
      directory = create :directory, :relative_path => path
      File.directory?(directory.path).should_not be_true
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
