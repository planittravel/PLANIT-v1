//
//  JRTicketCellProtocol.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#ifndef ASTTicketCellProtocol_h
#define ASTTicketCellProtocol_h
#import "PLANIT_v1-Swift.h"


@protocol JRTicketCellProtocol <NSObject>

- (void)applyFlight:(JRSDKFlight *)flight;

@end

#endif /* JRTicketCellProtocol_h */

