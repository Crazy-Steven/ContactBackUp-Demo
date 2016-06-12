//
//  ViewController.m
//  ContactBackUp-Demo
//
//  Created by 郭艾超 on 16/6/10.
//  Copyright © 2016年 Steven. All rights reserved.
//

#import "ViewController.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import <Photos/Photos.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Contact
- (IBAction)jumpToSystemContact:(UIButton *)sender {
    CNContactPickerViewController * contactVC = [[CNContactPickerViewController alloc]init];
    [self presentViewController:contactVC animated:YES completion:nil];
}

- (IBAction)addContact:(UIButton *)sender {
    CNMutableContact * contact = [[CNMutableContact alloc]init];
    
    contact.imageData = UIImagePNGRepresentation([UIImage imageNamed:@"naruto.jpg"]);
    
    contact.givenName = @"steven";//设置名字
    
    contact.familyName = @"guo";//设置姓氏
    
    contact.emailAddresses = @[[CNLabeledValue labeledValueWithLabel:CNLabelWork value:@"956995511@qq.com"]];//邮箱
    contact.phoneNumbers = @[[CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberiPhone value:[CNPhoneNumber phoneNumberWithStringValue:@"13999999999"]]];//电话
    
    //地址
    CNMutablePostalAddress * homeAdress = [[CNMutablePostalAddress alloc]init];
    homeAdress.street = @"大街";
    homeAdress.city = @"深圳";
    homeAdress.state = @"中国";
    homeAdress.postalCode = @"518000";
    contact.postalAddresses = @[[CNLabeledValue labeledValueWithLabel:CNLabelHome value:homeAdress]];
    //生日
    NSDateComponents * birthday = [[NSDateComponents  alloc]init];
    birthday.day=4;
    birthday.month=2;
    birthday.year=1989;
    contact.birthday=birthday;
    
    //初始化方法
    CNSaveRequest * saveRequest = [[CNSaveRequest alloc]init];
    //将创建的联系人添加到系统通讯录中
    [saveRequest addContact:contact toContainerWithIdentifier:nil];
    
    CNContactStore * store = [[CNContactStore alloc]init];
    [store executeSaveRequest:saveRequest error:nil];//保存前面创建的请求
    
}

- (IBAction)showContact:(UIButton *)sender {
    CNContactStore * stroe = [[CNContactStore alloc]init];
    CNContactFetchRequest * request = [[CNContactFetchRequest alloc]initWithKeysToFetch:@[CNContactIdentifierKey,CNContactFamilyNameKey,CNContactGivenNameKey,CNContactOrganizationNameKey,CNContactPhoneNumbersKey,CNContactEmailAddressesKey,CNContactPostalAddressesKey,CNContactImageDataKey]];
    NSMutableArray * arr = [@[] mutableCopy];
    [stroe enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        [arr addObject:contact];
        
    }];
    if  (arr.count > 0 ){
        [NSKeyedArchiver archiveRootObject:arr toFile:@"/Users/Crazy_Steven/Desktop/contact.xml"];
    }
}

#pragma mark - picture
- (IBAction)showPicture:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (IBAction)backUpPicture:(UIButton *)sender {
    NSMutableArray *dataArray = [NSMutableArray array];
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc]init];
    
    PHFetchResult *smartAlbumsFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:fetchOptions];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        [smartAlbumsFetchResult enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL *stop) {
            
            if (![collection.localizedTitle isEqualToString:@"Videos"]) {
                NSArray<PHAsset *> *assets = [self GetAssetsInAssetCollection:collection];
                for (PHAsset * asset in assets) {
                    [[PHImageManager defaultManager]requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                        [dataArray addObject:imageData];
                    }];
                }
            }
        }];

        PHFetchResult *smartAlbumsFetchResult1 = [PHAssetCollection fetchTopLevelUserCollectionsWithOptions:fetchOptions];
        [smartAlbumsFetchResult1 enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL *stop) {
            
            NSArray<PHAsset *> *assets = [self GetAssetsInAssetCollection:collection];
            for (PHAsset * asset in assets) {
                [[PHImageManager defaultManager]requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    [dataArray addObject:imageData];
                }];
            }
        }];
        [dataArray writeToFile:@"/Users/Crazy_Steven/Desktop/Photos.plist" atomically:YES];
    });
}

- (NSArray *)GetAssetsInAssetCollection:(PHAssetCollection *)assetCollection
{
    NSMutableArray<PHAsset *> *arr = [NSMutableArray array];
    
    PHFetchResult *result = [self GetFetchResult:assetCollection];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (((PHAsset *)obj).mediaType == PHAssetMediaTypeImage) {
            [arr addObject:obj];
        }
    }];
    return arr;
}

-(NSString *) FormatPhotoAlumTitle:(NSString *)title
{
    if ([title isEqualToString:@"All Photos"] || [title isEqualToString:@"Camera Roll"]) {
        return @"相机胶卷";
    }
    return nil;
}

-(PHFetchResult *)GetFetchResult:(PHAssetCollection *)assetCollection
{
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    return fetchResult;
    
}
@end