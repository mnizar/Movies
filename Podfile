platform :ios, '13.0'

def user_interface
    pod 'Kingfisher', '~> 6.3.0'
    pod 'SkeletonView', '~> 1.15.0'
end

def utilities
    pod 'RxSwift', '~> 6.2.0'
    pod 'RxCocoa', '~> 6.2.0'
    pod 'RealmSwift', '10.7.6'
end

target 'Movies' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Movies
  user_interface
  utilities

  target 'MoviesTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MoviesUITests' do
    # Pods for testing
  end

end
