require 'spec_helper'

describe BRocket::Docker do

  let(:subject){ BRocket::Docker.new }

  let(:image_name){ "groovenauts/rails-example" }
  let(:version){ "2.3.4" }

  let(:expected_options){ {"dockerfile"=>"Dockerfile"} }
  before do
    version_file = double(:version_file, current: version)
    allow(version_file).to receive(:options=).with(expected_options)
    allow(BRocket::VersionFile).to receive(:new).and_return(version_file)
  end

  describe "Dockerfile-basic" do
    let(:filepath){ File.expand_path("../Dockerfiles/Dockerfile-basic", __FILE__) }

    before do
      allow(subject).to receive(:read_config_file).with(any_args).and_return(File.read(filepath))
    end

    describe :config do
      it{ expect(subject.config_hash).to eq({"IMAGE_NAME" => image_name}) }
    end

    describe :build do
      it do
        expect(subject).to receive(:sh).with("docker build -t #{image_name}:#{version} .")
        subject.build
      end
    end
  end

  describe "Dockerfile-working_dir" do
    let(:filepath){ File.expand_path("../Dockerfiles/Dockerfile-working_dir", __FILE__) }
    let(:expected_options){ {dockerfile: filepath} }

    before do
      allow(subject).to receive(:read_config_file).with(any_args).and_return(File.read(filepath))
    end

    describe :config do
      it{ expect(subject.config_hash).to eq({"IMAGE_NAME" => image_name, "WORKING_DIR" => ".."}) }
    end

    describe :build do
      it do
        dir = File.expand_path("../..", filepath)
        expect(Dir).to receive(:chdir).with(dir).and_yield
        expect(subject).to receive(:sh).with("docker build -t #{image_name}:#{version} .")
        subject.options = {dockerfile: filepath}
        subject.build
      end
    end
  end


  describe "Dockerfile-basic" do
    let(:filepath){ File.expand_path("../Dockerfiles/Dockerfile-hook", __FILE__) }

    before do
      allow(subject).to receive(:read_config_file).with(any_args).and_return(File.read(filepath))
    end

    describe :config do
      it do
        expected = {
          "WORKING_DIR" => "..",
          "IMAGE_NAME" => image_name,
          "BEFORE_BUILD" => ["abc", "def ghi"],
          "AFTER_BUILD" => ["jkl", "mno"],
          "ON_BUILD_COMPLETE" => "foo bar",
          "ON_BUILD_ERROR" => "baz",
        }
        expect(subject.config_hash).to eq(expected)
      end
    end

    describe :build do
      it :success do
        expect(subject).to receive(:sh).with("abc")
        expect(subject).to receive(:sh).with("def ghi")
        expect(subject).to receive(:sh).with("docker build -t #{image_name}:#{version} .")
        expect(subject).to receive(:sh).with("foo bar")
        expect(subject).to receive(:sh).with("jkl")
        expect(subject).to receive(:sh).with("mno")
        subject.build
      end

      it :error do
        error_msg = "build error"
        expect(subject).to receive(:sh).with("abc")
        expect(subject).to receive(:sh).with("def ghi")
        expect(subject).to receive(:sh).with("docker build -t #{image_name}:#{version} .").and_raise(error_msg)
        expect(subject).to receive(:sh).with("baz") # not "foo bar"
        expect(subject).to receive(:sh).with("jkl")
        expect(subject).to receive(:sh).with("mno")
        expect{
          subject.build
        }.to raise_error(error_msg)
      end
    end
  end

end
