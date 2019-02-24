//
//  PreferenceWindow.m
//  MacVpnL2tp
//
//  Created by  沈江洋 on 21/10/2017.
//  Copyright © 2017  沈江洋. All rights reserved.
//

#import "PreferenceWindow.h"
#import "STPrivilegedTask.h"

const NSString* g_vpnName=@"MacVpnL2TP";

const NSString* g_serverKey=@"Server";
const NSString* g_userNameKey=@"UserName";
const NSString* g_passwordKey=@"Password";

@interface PreferenceWindow ()

@end

@implementation PreferenceWindow
{
    BOOL m_isConnected;
    BOOL m_isInfoChanged;
    NSTimer* m_firstConnectTimer;
    NSTimer* m_listenVPNTimer;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self setInitState];
}

- (void)setInitState
{
    [self loadFromLoginJson];
    m_isInfoChanged=false;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:NSTextDidChangeNotification object:nil];
    [[self btnConnect] setEnabled:NO];
    m_firstConnectTimer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(firstConnectVPN) userInfo:nil repeats:NO];
}

- (void)textDidChange:(NSNotification *)obj
{
    m_isInfoChanged=true;
}

- (IBAction)pressConnect:(NSButton *)sender
{
    [self executePressConnect];
}

- (IBAction)pressDisConnect:(NSButton *)sender
{
    [self executePressDisConnect];
}

-(void) executePressConnect
{
    [[self btnConnect] setEnabled:NO];
    if(!m_isInfoChanged)
    {
        [self connectVPN];
    }
    if(!m_isConnected)
    {
        //first text fields cannot be empty
        BOOL isSetup=[self setupVPN];
        if(isSetup)
        {
            m_firstConnectTimer=[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(firstConnectVPN) userInfo:nil repeats:NO];
        }
    }
}

-(void) executePressDisConnect
{
    [[self btnDisConnect] setEnabled:NO];
    [self disconnectVPN];
    [self updateConnectStatus];
}

-(void) firstConnectVPN
{
    //check options
    [m_firstConnectTimer invalidate];
    
    NSString *optionsString=[NSString stringWithContentsOfFile:@"/etc/ppp/options" encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"options string: %@",optionsString);
    if(optionsString==nil||[optionsString rangeOfString:@"plugin L2TP.ppp\nl2tpnoipsec\n"].length<=0)
    {
        BOOL copyResult=[self copyOptions];
        if(copyResult)
        {
//            [self logMessage:@"文件配置成功。"];
            [self logMessage:@"config file copied."];
            [self connectVPN];
            if(m_isConnected)
            {
                [self writeToLoginJson];
                m_isInfoChanged=false;
            }
        }
        else
        {
//            [self logMessage:@"文件配置失败。"];
            [self logMessage:@"config file not copied."];
            [[self tfUser]setEditable:NO];
            [[self stfPassword]setEditable:NO];
            [[self btnConnect] setEnabled:NO];
            [[self btnDisConnect] setEnabled:NO];
        }
    }
    else
    {
        [self connectVPN];
        if(m_isConnected)
        {
            [self writeToLoginJson];
            m_isInfoChanged=false;
        }
    }
}

- (void)logMessage:(NSString *)message
{
    if (message)
    {
        [self appendMessage:message];
    }
}

- (void)appendMessage:(NSString *)message
{
    NSString *messageWithNewLine = [message stringByAppendingString:@"\n\n"];
    
    // Smart Scrolling
    BOOL scroll = (NSMaxY(self.tvLog.visibleRect) == NSMaxY(self.tvLog.bounds));
    
    // Append string to textview
    [self.tvLog.textStorage appendAttributedString:[[NSAttributedString alloc]initWithString:messageWithNewLine]];
    
    if (scroll) // Scroll to end of the textview contents
        [self.tvLog scrollRangeToVisible: NSMakeRange(self.tvLog.string.length, 0)];
}

-(BOOL)copyOptions
{
//    [self logMessage:@"尝试进行文件配置。"];
    [self logMessage:@"trying to copy config file."];
    NSString *cmdString=@"/bin/sh ./copyoptions.sh";
    return [self runSTPrivilegedTask:cmdString];
}

-(BOOL)setupVPN
{
//    [self logMessage:@"尝试配置网络连接。"];
    [self logMessage:@"trying to setup vpn."];
    NSString* userString=[[_tfUser stringValue] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString* passwordString=[[_stfPassword stringValue] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString* serverString=[[_tfServer stringValue] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(userString.length==0||passwordString.length==0||serverString.length==0)
    {
//        [self logMessage:@"输入不能为空!"];
        [self logMessage:@"fill up the blanks, please."];
        [self updateConnectStatus];
        return NO;
    }
    NSString *cmdString=@"/bin/sh ./setupVPN.sh ";
    cmdString=[cmdString stringByAppendingString:g_vpnName];
    cmdString=[cmdString stringByAppendingString:@" "];
    cmdString=[cmdString stringByAppendingString:userString];
    cmdString=[cmdString stringByAppendingString:@" "];
    cmdString=[cmdString stringByAppendingString:passwordString];
    cmdString=[cmdString stringByAppendingString:@" "];
    cmdString=[cmdString stringByAppendingString:serverString];
    return [self runSTPrivilegedTask:cmdString];
}

-(void)connectVPN
{
//    [self logMessage:@"开始网络连接。"];
    [self logMessage:@"start to connect."];
    NSString* userString=[[_tfUser stringValue] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString* passwordString=[[_stfPassword stringValue] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString* serverString=[[_tfServer stringValue] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(userString.length==0||passwordString.length==0||serverString.length==0)
    {
//        [self logMessage:@"输入不能为空!"];
        [self logMessage:@"fill up the blanks, please."];
        [self updateConnectStatus];
    }
    else
    {
        NSString *cmdString=[@"/bin/sh ./connectVPN.sh " stringByAppendingString:g_vpnName];
        m_isConnected=[self runNSTask:cmdString];
        [self updateConnectStatus];
        if(m_isConnected)
        {
//            [self logMessage:@"网络已经连接!!!"];
            [self logMessage:@"connected!!!"];
            m_listenVPNTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(listenVPN) userInfo:nil repeats:YES];
        }
        else
        {
//            [self logMessage:@"网络连接失败!!!\n请确保wifi正确连接!!!\n并检查输入参数是否正确!!!\n并确保没有连接其他VPN!!!"];
            [self logMessage:@"failed!!!\ncheck parameters!!!\ncheck physical connection!!!\nmake sure no other vpn connected!!!"];
            m_isInfoChanged=true;
        }
    }
}

-(void) disconnectVPN
{
//    [self logMessage:@"断开网络连接。"];
    [self logMessage:@"start to disconnect."];
    NSString *cmdString=[@"/bin/sh ./disconnectVPN.sh " stringByAppendingString:g_vpnName];
    [self runNSTask:cmdString];
    m_isConnected=NO;
    [self updateConnectStatus];
//    [self logMessage:@"网络已经断开!!!"];
    [self logMessage:@"disconnected!!!"];
}

-(void) listenVPN
{
    //[self logMessage:@"listenVPN"];
    NSString *cmdString=[@"/bin/sh ./listenVPN.sh " stringByAppendingString:g_vpnName];
    BOOL listenConnectStatus=[self runNSTask:cmdString];
    
    if(!listenConnectStatus)
    {
        if(m_isConnected)
        {
            m_isConnected=NO;
            [self updateConnectStatus];
//            [self logMessage:@"网络已经断开!!!"];
            [self logMessage:@"disconnected!!!"];
        }
    }
}

- (BOOL)runNSTask:(NSString*) cmdstring
{
    
    NSTask *task = [[NSTask alloc] init];
    
    NSMutableArray *components = [[cmdstring componentsSeparatedByString:@" "] mutableCopy];
    task.launchPath = components[0];
    [components removeObjectAtIndex:0];
    task.arguments = components;
    task.currentDirectoryPath = [[NSBundle  mainBundle] resourcePath];
    
    NSPipe *outputPipe = [NSPipe pipe];
    [task setStandardOutput:outputPipe];
    [task setStandardError:outputPipe];
    NSFileHandle *readHandle = [outputPipe fileHandleForReading];
    
    [task launch];
    [task waitUntilExit];
    
    NSData *outputData = [readHandle readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    
    NSString *exitStr = [NSString stringWithFormat:@"Exit status: %d ......", task.terminationStatus];
    NSLog(exitStr);
    
    if(task.terminationStatus==0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)runSTPrivilegedTask:(NSString*) cmdstring
{
    
    STPrivilegedTask *privilegedTask = [[STPrivilegedTask alloc] init];
    
    NSMutableArray *components = [[cmdstring componentsSeparatedByString:@" "] mutableCopy];
    NSString *launchPath = components[0];
    [components removeObjectAtIndex:0];
    
    [privilegedTask setLaunchPath:launchPath];
    [privilegedTask setArguments:components];
    [privilegedTask setCurrentDirectoryPath:[[NSBundle mainBundle] resourcePath]];
    
    //set it off
    OSStatus err = [privilegedTask launch];
    if (err != errAuthorizationSuccess) {
        [self updateConnectStatus];
        if (err == errAuthorizationCanceled) {
//            [self logMessage:@"用户取消操作。"];
            [self logMessage:@"user canceled."];
            return NO;
        }  else {
//            [self logMessage:@"出现未知异常!"];
            [self logMessage:@"unknown error!"];
        }
    }
    
    [privilegedTask waitUntilExit];
    
    // Success!  Now, start monitoring output file handle for data
    NSFileHandle *readHandle = [privilegedTask outputFileHandle];
    NSData *outputData = [readHandle readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    
    NSString *exitStr = [NSString stringWithFormat:@"Exit status: %d ......", privilegedTask.terminationStatus];
    NSLog(exitStr);
    
    if(privilegedTask.terminationStatus==0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void) updateConnectStatus
{
    if(m_isConnected)
    {
        [[self tfUser]setEditable:NO];
        [[self stfPassword]setEditable:NO];
        [[self btnConnect] setEnabled:NO];
        [[self btnDisConnect] setEnabled:YES];
    }
    else
    {
        [m_listenVPNTimer invalidate];
        [[self tfUser]setEditable:YES];
        [[self stfPassword]setEditable:YES];
        [[self btnConnect] setEnabled:YES];
        [[self btnDisConnect] setEnabled:NO];
    }
    [_delegate updateConnectionStatus:m_isConnected];
}

-(void) loadFromLoginJson
{
    NSString *resourcepath = [[NSBundle mainBundle] resourcePath];
    NSString *contentPath = [resourcepath stringByAppendingString:@"/login.json"];
    NSString *loginJsonString=[NSString stringWithContentsOfFile:contentPath encoding:NSUTF8StringEncoding error:nil];
    NSError *err = nil;
    NSArray *arr =
    [NSJSONSerialization JSONObjectWithData:[loginJsonString dataUsingEncoding:NSUTF8StringEncoding]
                                    options:NSJSONReadingMutableContainers
                                      error:&err];
    NSMutableDictionary *dictionary = arr[0];
    NSString *serverString=[dictionary objectForKey:g_serverKey];
    NSString *userNameString=[dictionary objectForKey:g_userNameKey];
    NSString *passwordString=[dictionary objectForKey:g_passwordKey];
    [_tfServer setStringValue:serverString];
    [_tfUser setStringValue:userNameString];
    [_stfPassword setStringValue:passwordString];
}

-(void) writeToLoginJson
{
    NSString *userNameString=[_tfUser stringValue];
    NSString *passwordString=[_stfPassword stringValue];
    NSString *serverIPString=[_tfServer stringValue];
    NSDictionary * dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                 serverIPString, g_serverKey,
                                 userNameString, g_userNameKey,
                                 passwordString, g_passwordKey, nil];
    NSArray * arr = [NSArray arrayWithObjects:dictionary, nil];
    NSData * data = [NSJSONSerialization dataWithJSONObject:arr options:NSJSONWritingPrettyPrinted error:nil];
    NSString * string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    
    NSString *resourcepath = [[NSBundle mainBundle] resourcePath];
    NSString *contentPath = [resourcepath stringByAppendingString:@"/login.json"];
    [string writeToFile:contentPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end
