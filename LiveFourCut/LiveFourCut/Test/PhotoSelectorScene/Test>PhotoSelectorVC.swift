//
//  TestPhotoSelectorVC.swift
//  LiveFourCut
//
//  Created by Greem on 6/18/24.
//

import UIKit
import Combine
import Photos
import PhotosUI
extension Test.PhotoSelectorVC{
    final class ReSelectPhotoBtn: UIButton{
        init(){
            super.init(frame: .zero)
            var config = UIButton.Configuration.plain()
            config.attributedTitle = .init("사진 재선택", attributes: .init([.font: UIFont.systemFont(ofSize: 15, weight: .medium),
                                                                            .underlineStyle: NSUnderlineStyle.single.rawValue]))
            self.configuration = config
        }
        required init?(coder: NSCoder) {
            fatalError("Don't use storyboard")
        }
    }
}
extension Test{
    final class PhotoSelectorVC: LoadingVC{
        let thumbnailFrameView = ThumbnailFourFrameView()
        let thumbnailSelectorView = ThumbnailSelectorView()
        let selectDoneBtn = SelectDoneBtn()
        let pregress = UIProgressView(progressViewStyle: .bar)
        let reSelectPhotoBtn = ReSelectPhotoBtn()
        let navigationBackButton = NavigationBackButton()
        let titleLabel: UILabel = {
            let label = UILabel()
            label.text = "순서대로 선택하소~"
            label.font = .systemFont(ofSize: 25, weight: .bold)
            return label
        }()
        private let bottomView: UIView = .init()
        var limitedNumber:Int = 0
        private var launchedView:Bool = false
        private let vm:ThumbnailSelectorVM = .init()
        private var isPagingEnabled = false
        let thumbnailExecutor = ThumbnailExecutor()
        let videoExecutor = VideoExecutor()
        var cancellable = Set<AnyCancellable>()
        override func viewIsAppearing(_ animated: Bool) {
            super.viewIsAppearing(animated)
            if !launchedView{
                launchedView.toggle()
                openPickerVC()
            }
        }
        override func viewDidLoad() {
            super.viewDidLoad()
            Task{
                thumbnailExecutor.thumbnailsSubject
                    .receive(on: RunLoop.main)
                    .sink {[weak self] containers in
                        self?.thumbnailSelectorView.imageContainers = containers
                    }.store(in: &cancellable)
                vm.pagingAvailable.receive(on: RunLoop.main)
                    .sink { [weak self] pagingAvailable in
                        self?.selectDoneBtn.isHidden = !pagingAvailable
                        self?.thumbnailSelectorView.isHidden = pagingAvailable
                        self?.reSelectPhotoBtn.isHidden = !pagingAvailable
                        self?.isPagingEnabled = pagingAvailable
                    }.store(in: &cancellable)
                thumbnailExecutor.progressSubject.receive(on: RunLoop.main)
                    .sink { [weak self] progressNumber in
                        guard let self else {return}
                        UIView.animate(withDuration: 0.2) {
                            if !self.pregress.isHidden && progressNumber == 1{
                                self.pregress.isHidden = true
                            }else if self.pregress.isHidden && progressNumber != 1{
                                self.pregress.isHidden = false
                            }
                            self.pregress.progress = progressNumber
                        }
                    }.store(in: &cancellable)
                videoExecutor.progressSubject.receive(on: RunLoop.main)
                    .sink { [weak self] progressNumber in
                        self?.loadingProgressView?.progress = progressNumber
                    }.store(in: &cancellable)
                videoExecutor.videosSubject.receive(on: RunLoop.main)
                    .sink { [weak self] avassetContainers in
                        Task{@MainActor in
                            self?.dismissLoadingAlert{
                                let vc = PreviewVC()
                                self?.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    }.store(in: &cancellable)
            }
            thumbnailSelectorView.vm = vm
            thumbnailFrameView.vm = vm
            self.reSelectPhotoBtn.addTarget(self, action: #selector(Self.reselectPickerTapped(sender:)), for: .touchUpInside)
        }
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
        }
        override func configureLayout() {
            [titleLabel,thumbnailFrameView,bottomView].forEach{ view.addSubview($0) }
            [thumbnailSelectorView,selectDoneBtn,pregress,reSelectPhotoBtn].forEach{bottomView.addSubview($0)}
        }
        override func configureConstraints() {
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
                make.centerX.equalToSuperview()
            }
            thumbnailFrameView.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(12)
                $0.horizontalEdges.equalToSuperview().inset(24)
            }
            bottomView.snp.makeConstraints { make in
                make.top.equalTo(thumbnailFrameView.snp.bottom)
                make.bottom.equalTo(view.safeAreaLayoutGuide)
                make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            }
            thumbnailSelectorView.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.horizontalEdges.equalToSuperview().inset(24)
            }
            selectDoneBtn.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.height.equalTo(50)
                make.horizontalEdges.equalToSuperview().inset(24)
            }
            self.pregress.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.height.equalTo(2)
                make.horizontalEdges.equalToSuperview().inset(24)
            }
            reSelectPhotoBtn.snp.makeConstraints { make in
                make.top.equalTo(selectDoneBtn.snp.bottom).offset(8)
                make.centerX.equalToSuperview()
            }
        }
        override func configureNavigation() {
            self.view.addSubview(navigationBackButton)
            navigationBackButton.backgroundColor = .black
            
        }
        override func configureView() {
            self.view.backgroundColor = .systemBackground
            pregress.backgroundColor = .lightGray
            pregress.isHidden = true
            selectDoneBtn.action = { [weak self] in
                guard let self else {return}
                presentLoadingAlert(message: "라이브 포토 영상으로 변환 중...", cancelAction: { [weak self] in
                })
                Task{
                    await self.videoExecutor.run()
                }
            }
        }
        func openPickerVC(){
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.filter = .livePhotos
            config.selectionLimit = 4
            config.selection = .ordered
            let containerList = vm.selectImageContainerSubject.value
            config.preselectedAssetIdentifiers = containerList.compactMap({$0}).map(\.id)
            let phVC = PHPickerViewController(configuration: config)
            phVC.delegate = self
            self.present(phVC , animated: true)
        }
        func denyPagingOrder(){
            let alertController = UIAlertController(title: "4장을 선택해주세요", message: nil, preferredStyle: .alert)
            alertController.addAction(.init(title: "돌아가기", style: .cancel,handler: {[weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }))
            alertController.addAction(.init(title: "다시 선택하기", style: .default, handler: {[weak self] _ in
                self?.openPickerVC()
            }))
            self.present(alertController, animated: true)
        }
    }
}
extension Test.PhotoSelectorVC:PHPickerViewControllerDelegate{
    @objc func reselectPickerTapped(sender: UIButton){
        openPickerVC()
    }
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let identifiers = results.map(\.assetIdentifier).map{$0!}
        let assets:PHFetchResult<PHAsset> = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        let containerList = vm.selectImageContainerSubject.value
        if Set(identifiers) == Set(containerList.compactMap({$0}).map(\.id)) && identifiers.count == 4{
            self.dismiss(animated: true)
            return
        }
        if identifiers.count == 4{
            self.selectDoneBtn.isHidden = true
            self.reSelectPhotoBtn.isHidden = true
            self.pregress.isHidden = false
            self.thumbnailSelectorView.isHidden = false
            self.thumbnailSelectorView.reset()
            self.thumbnailFrameView.reset()
            self.vm.resetSelectImage()
        }
        self.dismiss(animated: true){[weak self] in
            if assets.count == 0{
                if !(self?.isPagingEnabled ?? false){
                    self?.navigationController?.popViewController(animated: true)
                }
            }else if assets.count == 4{
                Task{
                    await self?.thumbnailExecutor.setFetchResult(result:assets)
                    await self?.videoExecutor.setFetchResult(result: assets)
                    await self?.thumbnailExecutor.run()
                }
            }else{
                self?.denyPagingOrder()
            }
        }
    }
}
