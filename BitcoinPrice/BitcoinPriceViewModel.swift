//
//  BitcoinPriceViewModel.swift
//  BitcoinPrice
//
//  Created by Lucas Parreira on 20/02/22.
//

import Foundation
import Combine

class BitcoinPriceViewModel: ObservableObject {
    @Published public private(set) var lastUpdated: String = ""
    @Published public private(set) var priceDetails: [PriceDetails] = Currency.allCases.map {
        PriceDetails(currency: $0)
    }
    
    private var subscription: AnyCancellable?
    
    public func onAppear() {
        subscription = CoindeskAPIService.shared
            .fetchBitcoinPrice()
            .sink(receiveCompletion: { completion in
                switch completion{
                case .failure(let error):
                    print(error.localizedDescription)
                case .finished:
                    print("success!")
                }
            }, receiveValue: { [weak self] value in
                guard let self = self else { return }
                self.lastUpdated = value.time.updated
                self.priceDetails = [
                    PriceDetails(currency: .usd, rate: value.bpi.USD.rate),
                    PriceDetails(currency: .gbp, rate: value.bpi.GBP.rate),
                    PriceDetails(currency: .eur, rate: value.bpi.EUR.rate)
                ]
            })
    }
}
