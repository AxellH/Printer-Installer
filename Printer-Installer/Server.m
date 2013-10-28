//
//  Server.m
//  SerialImportDS
//
//  Created by Eldon Ahrold on 8/14/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "Server.h"

@implementation Server
-(id)initWithURL:(NSString*)url{
    self = [super init];
    if (self) {
        self.URL= [NSURL URLWithString:url];
    }
    return self;
}

-(void)setBasicHeaders:(NSString*)header{
    self.authHeader = [ NSString stringWithFormat:@"Basic %@",header];
}


-(void)setGetListPath{
    self.path =  [NSString stringWithFormat:@"%@",self.path];
}


-(void)postRequestWithData{        
    NSError* error = nil;
    NSURLResponse* response = nil;
    
    // Create the request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.URL];
    
    // set as POST request
    request.HTTPMethod = @"POST";
    
    // set header fields
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    if(self.authHeader){
        [request setValue:self.authHeader forHTTPHeaderField:@"Authorization"];
    }
    // Convert data and set request's HTTPBody property
    [request setHTTPBody:self.requestData];
    
    // Create url connection and fire request
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    self.response = response;
    self.error = error;
}


-(NSDictionary*)getRequest{
    NSError* error = nil;
    NSURLResponse* response = nil;
        
    // Create the request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.URL];
        
    // set as GET request
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 3;
    
    // set header fields
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    if(self.authHeader){
        [request setValue:self.authHeader forHTTPHeaderField:@"Authorization"];
    }
        
    // Convert data and set request's HTTPBody property
    [request setHTTPBody:self.requestData];
    
    // Create url connection and fire request
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSDictionary* dict;
    self.response = response;

    if(error){
        self.error = error;
        return nil;
    }
    
    NSPropertyListFormat plist;
    dict = (NSDictionary*)[NSPropertyListSerialization
                           propertyListWithData:data
                           options:NSPropertyListMutableContainersAndLeaves
                           format:&plist
                           error:&error];
    
    if(error){
        self.error = error;
    }
    
    return dict;
}

-(void)downloadPPD:(NSString**)ppd{
    NSError* error = nil;
    NSURLResponse* response = nil;
    
    // Create the request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.URL];
    
    // set as GET request
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 3;
    
    // set header fields
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    if(self.authHeader){
        [request setValue:self.authHeader forHTTPHeaderField:@"Authorization"];
    }
    
    // Convert data and set request's HTTPBody property
    //[request setHTTPBody:self.requestData];
    
    // Create url connection and fire request
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    self.response = response;
    
    NSString* _ppd = [NSTemporaryDirectory() stringByAppendingPathComponent:@"printer-installer.ppd"];
    
    NSInteger rc = [((NSHTTPURLResponse *)response) statusCode];
    if(error){
        self.error = error;
    }
    else if(rc == 404 || rc == 500){
        NSDictionary* d = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"Server returned a %ld error",(long)rc],@"forKey:NSLocalizedDescriptionKey",nil ];
        self.error = [[NSError alloc]initWithDomain:@"Web Server" code:rc userInfo:d];
    }else{
        [[NSFileManager defaultManager] createFileAtPath:_ppd contents:data attributes:nil];
        *ppd = _ppd;
    }
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)space {
    return YES;
}


@end
