# Command: backend-module

## Mô tả
Tạo một NestJS module mới theo đúng pattern chuẩn của tapl-chainlink backend.

## Khi được yêu cầu tạo module mới, LUÔN tạo đủ các file sau:

```
src/modules/{module-name}/
  {module-name}.module.ts
  {module-name}.controller.ts   (nếu có REST API)
  {module-name}.service.ts
  {module-name}.repository.ts
  entities/
    {module-name}.entity.ts
  dto/
    create-{module-name}.dto.ts
    update-{module-name}.dto.ts
    query-{module-name}.dto.ts
  interfaces/
    {module-name}.interface.ts
  {module-name}.spec.ts
```

## Template: Module
```typescript
@Module({
  imports: [TypeOrmModule.forFeature([{ModuleName}Entity])],
  controllers: [{ModuleName}Controller],
  providers: [{ModuleName}Service, {ModuleName}Repository],
  exports: [{ModuleName}Service],
})
export class {ModuleName}Module {}
```

## Template: Service
```typescript
@Injectable()
export class {ModuleName}Service {
  private readonly logger = new Logger({ModuleName}Service.name);

  constructor(
    @InjectRepository({ModuleName}Entity)
    private readonly repo: Repository<{ModuleName}Entity>,
    private readonly redisService: RedisService,
    private readonly kafkaProducer: KafkaProducerService,
  ) {}

  async create(dto: Create{ModuleName}Dto): Promise<{ModuleName}Entity> {
    this.logger.log(`Creating {moduleName}: ${JSON.stringify(dto)}`);
    const entity = this.repo.create(dto);
    const saved = await this.repo.save(entity);
    await this.kafkaProducer.send('{module-name}.created', saved);
    return saved;
  }

  async findById(id: string): Promise<{ModuleName}Entity> {
    const entity = await this.repo.findOne({ where: { id } });
    if (!entity) throw new NotFoundException(`{ModuleName} ${id} not found`);
    return entity;
  }

  async findByUser(userId: string): Promise<{ModuleName}Entity[]> {
    return this.repo.find({ where: { userId }, order: { createdAt: 'DESC' } });
  }
}
```

## Template: Entity
```typescript
@Entity('{module_name}s')
export class {ModuleName}Entity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  userId: string;

  @ManyToOne(() => UserEntity)
  @JoinColumn({ name: 'user_id' })
  user: UserEntity;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
```

## Template: DTO
```typescript
export class Create{ModuleName}Dto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsNumber()
  @Min(0)
  amount: number;
}

export class Query{ModuleName}Dto {
  @IsOptional()
  @IsUUID()
  userId?: string;

  @IsOptional()
  @IsEnum({ModuleName}Status)
  status?: {ModuleName}Status;
}
```

## Template: Controller
```typescript
@Controller('{module-name}s')
@UseGuards(JwtAuthGuard)
export class {ModuleName}Controller {
  constructor(private readonly service: {ModuleName}Service) {}

  @Post()
  create(@Body() dto: Create{ModuleName}Dto, @CurrentUser() user: UserEntity) {
    return this.service.create({ ...dto, userId: user.id });
  }

  @Get(':id')
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.service.findById(id);
  }

  @Get()
  findAll(@Query() query: Query{ModuleName}Dto) {
    return this.service.findByUser(query.userId);
  }
}
```

## Template: Unit Test
```typescript
describe('{ModuleName}Service', () => {
  let service: {ModuleName}Service;
  let repo: jest.Mocked<Repository<{ModuleName}Entity>>;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        {ModuleName}Service,
        { provide: getRepositoryToken({ModuleName}Entity), useValue: createMockRepo() },
        { provide: RedisService, useValue: createMockRedis() },
        { provide: KafkaProducerService, useValue: createMockKafka() },
      ],
    }).compile();
    service = module.get({ModuleName}Service);
    repo = module.get(getRepositoryToken({ModuleName}Entity));
  });

  it('creates and emits kafka event', async () => {
    const dto = { name: 'test', amount: 100 };
    await service.create(dto);
    expect(repo.save).toHaveBeenCalled();
    expect(kafkaProducer.send).toHaveBeenCalledWith('{module-name}.created', expect.any(Object));
  });

  it('throws NotFoundException when not found', async () => {
    repo.findOne.mockResolvedValue(null);
    await expect(service.findById('bad-id')).rejects.toThrow(NotFoundException);
  });
});
```

## Sau khi tạo module, nhớ:
1. Import vào `app.module.ts`
2. Chạy `yarn migration:generate` nếu có entity mới
3. Thêm Kafka consumer nếu module cần lắng nghe events từ module khác
4. Với modules liên quan đến EVM (payment, settlement): inject `TapOrderAdapter` từ `adapters/`
