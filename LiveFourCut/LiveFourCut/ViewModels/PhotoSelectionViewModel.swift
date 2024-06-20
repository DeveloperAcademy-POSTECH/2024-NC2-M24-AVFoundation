//
//  PhotoSelectionViewModel.swift
//  LiveFourCut
//
//  Created by Greem on 6/20/24.
//

import Foundation
import UIKit
import Combine
final class ThumbnailSelectorVM{
    let selectImageContainerSubject: CurrentValueSubject<[ImageContainer?],Never> = .init([nil,nil,nil,nil])
    lazy var pagingAvailable = selectImageContainerSubject.map{ !$0.contains(where: {$0 == nil}) }.eraseToAnyPublisher()
    lazy var selectedImageIndexes = selectImageContainerSubject.map{ containerList in
        (0..<4).map({containerList.map(\.?.idx).contains($0)})
    }.eraseToAnyPublisher()
    private var imageContainers:[ImageContainer] = []
    init(){ }
    func setFetchedImageContainers(_ imageContainers:[ImageContainer]){
        self.imageContainers = imageContainers
    }
    @discardableResult
    func appendSelectImage(container:ImageContainer)->Int{
        var currentSubjectValue = self.selectImageContainerSubject.value
        let firstIdx = currentSubjectValue.firstIndex(where: {$0 == nil}).map{Int($0)}!
        currentSubjectValue[firstIdx] = container
        selectImageContainerSubject.send(currentSubjectValue)
        return firstIdx
    }
    func removeSelectImage(idx:Int){
        var currentSubjectValue = self.selectImageContainerSubject.value
        let firstIdx = currentSubjectValue.firstIndex(where: {$0?.idx == idx}).map{Int($0)}!
        currentSubjectValue[firstIdx] = nil
        selectImageContainerSubject.send(currentSubjectValue)
    }
    func removeSelectImage(containerID:ImageContainer.ID){
        var currentSubjectValue = self.selectImageContainerSubject.value
        let firstIdx = currentSubjectValue.firstIndex(where: {$0?.id == containerID}).map{Int($0)}!
        currentSubjectValue[firstIdx] = nil
        selectImageContainerSubject.send(currentSubjectValue)
    }
    func resetSelectImage(){
        selectImageContainerSubject.send([nil,nil,nil,nil])
    }
}
