//
//  Task.swift
//  Card Note
//
//  Created by Wei Wei on 1/11/19.
//  Copyright © 2019 WeiQiang. All rights reserved.
//

import Foundation
@objc protocol TaskProtocal{
    func finish()
}

class Task{
    var task:()->()
    weak var delegate:TaskProtocal?
    init(task:@escaping ()->()) {
        self.task = task
    }
    
    func run(){
        task()
    }
    
    func finish(){
        if(delegate != nil){
            delegate?.finish()
        }
    }
}

class TaskQueue:TaskProtocal{
    private var tasks:[Task]
    init() {
        tasks = [Task]()
    }
    
    init(tasks:[Task]) {
        self.tasks = tasks
        for task in tasks{
            task.delegate = self
        }
    }
    
    func add(task:Task){
        tasks.append(task)
    }
    
    func remove()->Task{
        return tasks.removeFirst()
    }
    
    func run() throws{
        if(!tasks.isEmpty){
            remove().run()
        }else{
            throw TaskQueueError.EmptyQueueException
        }
    }
    
    internal func finish() {
        if(!tasks.isEmpty){
            remove().run()
        }
    }
}

enum TaskQueueError:Error{
    case EmptyQueueException
}
