//
//  JKScoresCustomTableViewCell.h
//  JKMinesweeper
//
//  Created by Jayesh Kawli Backup on 12/26/14.
//  Copyright (c) 2014 Jayesh Kawli. All rights reserved.
//

@interface JKScoresCustomTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *sequence;
@property (weak, nonatomic) IBOutlet UILabel *playerName;
@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UILabel *gameLevel;

@end
