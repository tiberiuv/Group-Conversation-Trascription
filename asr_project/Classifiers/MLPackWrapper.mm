//
//  MLPackWrapper.mm
//  asr_project
//
//  Created by Tiberiu Simion Voicu on 27/02/2018.
//  Copyright © 2018 Tiberiu Simion Voicu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mlpack/methods/gmm/gmm.hpp>
#import "MLPackWrapper.h"

@implementation MLPackWrapper : NSObject

- (void)build_classifier:(double*) features and_size:(uint32_t) size {
    mlpack::gmm::GMM gmm(4,12);
//    arma::fmat train_matrix;
    arma::dmat train_matrix(features, size, 12);
//    gmm.Train(train_matrix);

    std::cout << "Index 1 of features :"<< features[1] << std::endl;
    std::cout << "Index 1 of train_matrix" << train_matrix(0) << std::endl;
}

 @end
